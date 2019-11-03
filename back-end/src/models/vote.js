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
}

module.exports = new Vote();