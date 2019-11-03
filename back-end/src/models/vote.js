var newClient = require('../helpers/mongo');
var bcrypt = require("bcrypt")

class Vote {
    async voteForSong(req, res){
        var { party_code, user_id, song_id } = req.body

        const client = newClient();
        client.connect(async (err, cli) => { 
            const db =  cli.db("boom-box")
            db.collection("parties").updateOne({'party_code': party_code, "song_nominations.id": song_id},
                {$inc: {"song_nominations.$.votes": 1}})
            .then(result => {
                res.status(200).send("Upvoted");
            })
            .catch(result => {
                res.status(400).send("Something fucked up");
            })
        });

        client.close()
    }
}

module.exports = new Vote();