var newClient = require('../helpers/mongo');
var bcrypt = require("bcrypt")

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
            const party = await db.collection("parties").findOne({'party_code': party_code})

            const songDuration = party.now_playing.duration_ms

            const options = {
                uri: "https://api.spotify.com/v1/me/player", 
                headers: {'Authorization': 'Bearer ' + token}
            }

            setInterval(() => {
                request(options)
                .then(err, res, body => {
                    var progress = body.progress_ms

                    if(songDuration - progress < 10000){
                        clearInterval();
                        // add highest rated song to playlist
                    }
                    res.status(200).send(body);
                })
                .catch(err => {
                    console.log(err)
                    res.status(400).send("Something fucked up");
                })
            } ,10000)





        });

        client.close()
    }
}

module.exports = new Vote();