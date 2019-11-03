var client = require('../helpers/mongo');
var bcrypt = require("bcrypt")

class Party {
    async joinParty(req, res){
        var { party_code, user_id } = req.body

        client.connect(async (err, cli) => { 
            const db =  cli.db("boom-box")
            const result = await db.collection("parties").updateOne({party_code: party_code}, {$push: {guests: user_id}})

            if (result.result.nModified === 1) {
                res.status(200).send("You're in!");
            } else {
                res.status(400).send("You fucked up");
            }
        });

        client.close();
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

    async getPartyInfo(req, res){
        res.status(200).send("Select random users");
    }
}

module.exports = new Party();