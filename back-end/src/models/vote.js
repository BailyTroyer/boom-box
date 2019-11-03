var newClient = require('../helpers/mongo');
var Playback = require('./playback')
var request = require('request-promise-native');


class Vote {
    async voteForSong(req, res){
        var { party_code, user_id, song_id } = req.body

        const client = newClient();
        client.connect(async (err, cli) => { 
            const db =  cli.db("boom-box");
            db.collection("parties").findOneAndUpdate(
                {'party_code': party_code}, 
                {$inc: {'song_nominations.$[elem].votes': 1}},
                {arrayFilters: [{'elem.song_id': song_id  }]})

            .then(result => {
                res.status(200).send("Upvoted");
            })
            .catch(result => {
                res.status(400).send("A small piece of me died inside");
            })
        });

        client.close();
    }

    async checkForSongEndingSoon(party_code, token){
        const client = newClient();
        client.connect(async (err, cli) => { 
            const db =  cli.db("boom-box")
            

            const options = {
                method: 'GET',
                uri: "https://api.spotify.com/v1/me/player", 
                headers: {'Authorization': 'Bearer ' + token},
                json: false
            }

            setInterval(async () => {
                const party = await db.collection("parties").findOne({'party_code': party_code})
                const songDuration = party.now_playing.duration_ms


                request(options)
                .then( async (err, res, body) => {
                    console.log(body)
                    console.log(res)
                    var progress = body.progress_ms

                    if(songDuration - progress < 10000){
                        // add highest rated song to playlist
                        const party = await db.collection("parties").findOne({'party_code': party_code})
                        var nominations = party.song_nominations
                        nominations.sort(this.sortByVotes)
                        const nextSong = nominations[0]

                        Playback.addSongToPlaylist(nextSong, party.playlist.id, token)

                        // checking for new song to play
                        setInterval(() => {
                            request(options)
                            .then((err, res, body) => {
                                // the song has changed, stop waiting
                                if(body.item.id !== party.now_playing.id){
                                    clearInterval();
                                    // update party info
                                    db.collection("parties").updateOne({party_code: party_code}, {now_playing: nextSong})
                                    .then(result => {})
                                    .catch(result => {})
                                }
                            })
                            .catch(err => {})
                        }, 2000)

                    }
                })
                .catch(err => {
                    console.log(err)
                })
            } ,10000)
        });

        client.close()
    }

    sortByVotes(firstEl, secondEl){
        if(firstEl.votes < secondEl.votes) return -1;
        if(firstEl.votes > secondEl.votes) return 1;
        return 0
    }
}



module.exports = new Vote();