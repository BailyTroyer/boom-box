var db = require('../helpers/mongo');
var bcrypt = require("bcrypt")

class Search {
    async seacrhForSong(req, res){
        res.status(200).send("Search for song");
    }
}

module.exports = new Search();