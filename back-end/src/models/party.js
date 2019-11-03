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

    async emergency(req, res){
        
        const db =  cli.db("boom-box")
        const curr_songs = await db.collection("parties").findAndModify(
            query: {party_code: party_code}, 
            update: {$inc: {cops: 1} }
        )

        if (result.result.nModified === 1) {
            res.status(200).send("Cops joined the party");
        } else {
            res.status(400).send("Something fucked up");
        }
    });

    client.close();
    }

    }
}

module.exports = new Party();