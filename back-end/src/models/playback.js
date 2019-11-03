var newClient = require('../helpers/mongo');

class Playback {
    async pauseMusic(req, res){
        var { party_code } = req.body

        const client = newClient();
        client.connect(async (err, cli) => { 
            const db =  cli.db("boom-box")
            const party = await db.collection("parties").findOne({'party_code': party_code})

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

module.exports = new Playback();