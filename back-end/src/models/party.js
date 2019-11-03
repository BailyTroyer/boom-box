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

    async nominateSong(req, res){
        res.status(200).send("Nominate song");
    }

    async removeNomination(req, res){
        res.status(200).send("Remove song nomination");
    }

    async selectRandomUsers(req, res){
        res.status(200).send("Select random users");
    }
}

module.exports = new Party();