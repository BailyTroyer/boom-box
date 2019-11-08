import { MongoClient } from 'mongodb';


const uri = "mongodb+srv://db_user:Password123@cluster0-alpf4.gcp.mongodb.net/test?retryWrites=true&w=majority";

const newClient = () => {
    return new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });
}

export default newClient;