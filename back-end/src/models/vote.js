import Mongo from '../helpers/mongo';

class Vote {
    static async voteForSong(req, res){
        const { party_code, user_id, song_id, vote } = req.body

        Mongo.db.collection("parties").findOneAndUpdate(
            {'party_code': party_code}, 
            {$inc: {'song_nominations.$[elem].votes': vote ? 1 : -1}},
            {arrayFilters: [{'elem.id': song_id }]}
        )

        .then(result => {
            res.status(200).send("Upvoted");
        })
        .catch(result => {
            res.status(400).send("A small piece of me died inside");
        })
    }
}

export default Vote;