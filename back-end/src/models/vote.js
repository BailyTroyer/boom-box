var db = require('../helpers/mongo');
var bcrypt = require("bcrypt")

class Vote {
    async voteForSong(req, res){
        res.status(200).send("Vote for song");
    }
}

module.exports = new Vote();