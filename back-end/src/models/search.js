import request from 'request-promise-native';

class Search {
    static async searchForSong(req, res){
        res.status(200).send("Search for song");
    }
}

export default Search;