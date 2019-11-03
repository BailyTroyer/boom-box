var db = require('../helpers/mongo');
var bcrypt = require("bcrypt")

class Vote {
    async voteForSong(req, res){
        var { party_code, user_id, song_id } = req.body

        client.connect(async (err, cli) => { 
            const db =  cli.db("boom-box")
            const curr_songs = await db.collection("parties").findAndModify(
                {query: {'party_code': party_code}}, 
                {$inc: {'song_queue.$[elem].votes': 1}},
                {arrayFilters: [{'elem.song_id': song_id  }]} );
            if (result.result.nModified === 1) {
                res.status(200).send("Upvoted");
            } else {
                res.status(400).send("Something fucked up");
            }
        });

        client.close();
    }
}

module.exports = new Vote();