var client = require('../helpers/mongo');
var bcrypt = require("bcrypt")


class Party {
    async joinParty(req, res){
        const { party_code, user_id } = req.body

        client.connect((err, cli) => { 
            const db =  cli.db("boom-box")
            db.collection("parties").updateOne({party_code: party_code}, {$push: {guests: user_id}})
            .then(result => {
                // add party to user document
                db.collection("users").updateOne({user_id: user_id}, {party_code: party_code, host: true})
                .then(result => {
                    res.status(200).send("You're in!");
                })
                .catch(result => {
                    res.status(400).send("You fucked up");
                })  
            })
            .catch(result => {
                res.status(400).send("You fucked up");
            })
        });
        client.close();
    }

    async leaveParty(req, res){
        const { user_id } = req.body

        client.connect((err, cli) => {
            const db =  cli.db("boom-box")

            db.collection("users").updateOne({user_id: user_id}, {party_code: null, host: false})
            .then(result => {
                res.status(200).send("You're out!");
            })
            .catch(result => {
                res.status(400).send("You fucked up");
            })
        });

        client.close();
    }

    async endParty(req, res){
        const { party_code } = req.body

        client.connect(async (err, cli) => { 
            const db =  cli.db("boom-box")
            
            const party = await db.collection("parties").findOne({party_code: party_code})
            
            for(var guest_id in party.guests){
                db.collection("users").updateOne({user_id: guest_id}, {party_code: null})
            }

            db.collection("parties").deleteOne({party_code: party_code})
            .then(result => {
                res.status(200).send("Ended party");
            })
            .catch(result => {
                res.status(400).send("You fucked up");
            })
        });
        client.close();   
    }

    async createParty(req, res){
        const { party_code, size, name } = req.body

        client.connect((err, cli) => { 
            const db =  cli.db("boom-box")

            db.collection("parties").insertOne({party_code: party_code, size: size, name: name})
            .then(result => {
                res.status(200).send("Created party");
            })
            .catch(result => {
                res.status(400).send("You fucked up");
            })
        });
        client.close();
    }


    async nominateSong(req, res){
        const { party_code, song } = req.body

        client.connect((err, cli) => { 
            const db =  cli.db("boom-box")

            db.collection("parties").insertOne({party_code: party_code, size: size, name: name})
            .then(result => {
                res.status(200).send("Nominate song");
            })
            .catch(result => {
                res.status(400).send("You fucked up");
            })
        });
        client.close();
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