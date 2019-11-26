import { MongoClient } from 'mongodb';


const uri = "mongodb+srv://db_user:Password123@cluster0-alpf4.gcp.mongodb.net/test?retryWrites=true&w=majority";
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });

class Mongo {
    constructor(){
        this.db = null
    }

    async connect(){
        const connectionPromise = new Promise((resolve, reject) => {
            client.connect((err, cli) => {
                if(err){
                    reject()
                }
                else {
                   this.db =  cli.db("boom-box") 
                   resolve()
                } 
            }) 
        })
        await connectionPromise
    }
}

const myMongo = new Mongo()

export default myMongo;