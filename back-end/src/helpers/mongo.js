const MongoClient = require('mongodb').MongoClient;
const uri = "mongodb+srv://db_user:Password123@cluster0-alpf4.gcp.mongodb.net/test?retryWrites=true&w=majority";

const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });

var db;

client.connect(async (err, database) => {
    const users = client.db("boombox").collection("users");
    
    db = database
    const some = await users.find().toArray();
    console.log(some)
    // perform actions on the collection object
    client.close();
});

 module.exports = db;
