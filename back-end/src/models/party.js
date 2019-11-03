var db = require('../helpers/mongo');
var bcrypt = require("bcrypt")

class Party {
    async joinParty(req, res){
        res.status(200).send("Join party");
    }

    async endParty(req, res){
        res.status(200).send("End party");
    }

    async createParty(req, res){
        res.status(200).send("Create party");
    }
}

module.exports = new Party();