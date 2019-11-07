import newClient from '../helpers/mongo';
import Playback from './playback'
import request from 'request-promise-native';


class Vote {
    static async voteForSong(req, res){
        const { party_code, user_id, song_id } = req.body

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

    static async checkForSongEndingSoon(party_code, token){
        const client = newClient();
        client.connect(async (err, cli) => { 
            const db =  cli.db("boom-box")
            

            const options = {
                method: 'GET',
                uri: "https://api.spotify.com/v1/me/player", 
                headers: {'Authorization': 'Bearer ' + token},
                json: true
            }

            setInterval(async () => {
                const party = await db.collection("parties").findOne({'party_code': party_code})
                //console.log(party.now_playing)
                const songDuration = party.now_playing.duration_ms


                request(options)
                .then(async (body) => {
                    // spotify is not open on any of the user's devices
                    if(!body){return}
                    // the user hasnt started the party playlist
                    if(body.item.id !== party.now_playing.id){
                        console.log(`Start playing - ${party.now_playing.name} - in the party playlist`)
                        return
                    }
                    
                    const progress = body.progress_ms

                    console.log(progress + ' / ' + songDuration)

                    if(songDuration - progress < 10000){
                        console.log("Last 10 seconds")
                        // add highest rated song to playlist
                        const party = db.collection("parties").findOne({'party_code': party_code})
                        const nominations = party.song_nominations
                        nominations.sort(sortByVotes)
                        const nextSong = nominations[0]

                        console.log(`Next song: ${nextSong.name}`)

                        Playback.addSongToPlaylist(nextSong, party.playlist.id, token)

                        // checking if new song has started playing
                        setInterval(() => {
                            console.log("New song started")
                            request(options)
                            .then((body) => {
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
            }, 8000)
        });

        client.close()
    }
}

const sortByVotes = (firstEl, secondEl) => {
    if(firstEl.votes < secondEl.votes) return -1;
    if(firstEl.votes > secondEl.votes) return 1;
    return 0
}


export default Vote;