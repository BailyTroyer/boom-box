import { MongoClient } from 'mongodb';


const uri = "mongodb+srv://db_user:Password123@cluster0-alpf4.gcp.mongodb.net/test?retryWrites=true&w=majority";

class Mongo {
    constructor(){
        this.db = null
        const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });
        client.connect((err, cli) => { 
            this.db =  cli.db("boom-box")
        })
    }
}

const myMongo = new Mongo()

export default myMongo;