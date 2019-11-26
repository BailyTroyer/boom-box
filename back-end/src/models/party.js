import Mongo from '../helpers/mongo';
import Playback from './playback'
import Vote from './vote'
import request from 'request-promise-native';


class Party {
    static async joinParty(req, res){
        const { party_code, user_id } = req.body

        const party = await Mongo.db.collection("parties").findOne({party_code: party_code})

        if(!party){
            res.status(404).send("That party doesnt exist!");
            return
        }

        Mongo.db.collection("parties").updateOne({party_code: party_code}, {$push: {guests: user_id}})
        .then(result => {
            // add party to user document
            Mongo.db.collection("users").updateOne({user_id: user_id}, {$set: {party_code: party_code, host: false}}, { upsert: true })
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
    }

    static async leaveParty(req, res){
        const { user_id, party_code } = req.body

        Mongo.db.collection("users").updateOne({user_id: user_id}, {$set: {party_code: null, host: false}})
        .then(result => {
            Mongo.db.collection("parties").updateOne({party_code: party_code}, {$pull: {guests: user_id}})
            .then(result => {
                res.status(200).send("You're out!");
            })
            .catch(result => {
                console.log(result)
            })
        })
        .catch(result => {
            console.log(result)
            res.status(400).send("You fucked up");
        })
    }

    static async endParty(req, res){
        const { party_code } = req.body
            
        const party = await Mongo.db.collection("parties").findOne({party_code: party_code})
        
        for(let guest_id in party.guests){
            Mongo.db.collection("users").updateOne({user_id: guest_id}, {party_code: null, host: false})
        }

        Mongo.db.collection("parties").deleteOne({party_code: party_code})
            .then(result => {
                res.status(200).send("Ended party");
            })
            .catch(result => {
                res.status(400).send("You fucked up");
            })  
    }

    static async createParty(req, res){
        const { party_code, size, name, token, starter_song, user_id } = req.body

        const [songInfo, playlist] = await Promise.all([
            Playback.getSongInfo(starter_song, token),
            createPartyPlaylist(name, user_id, token)
        ])

        await Playback.addSongToPlaylist(songInfo, playlist.id, token)

        Mongo.db.collection("parties").insertOne({
            now_playing: songInfo,
            playlist: playlist,
            party_code: party_code, 
            size: size, 
            name: name, 
            token: token, 
            song_nominations: [],
            guests: [],
            cops: 0
        })
            .then(result => {
                //start playing playlist
                startParty(playlist.id, token);
                res.status(200).send(playlist.id);
            })
            .catch(result => {
                console.log(result)
                res.status(400).send("You fucked up");
            })

        // runs for the life of the party
        Vote.checkForSongEndingSoon(party_code, token);
    }

    static async nominateSong(req, res){
        const { party_code, song_url, token } = req.body

        const [songInfo, party] = await Promise.all([
            Playback.getSongInfo(song_url, token),
            Mongo.db.collection("parties").findOne({party_code: party_code})
        ])

        songInfo.votes = 0 // add key to object

        // if the song is already in the nominations
        if(party.song_nominations.find(song => song.id === songInfo.id)){
            res.status(200).send("Song already nominated");
            return
        }

        Mongo.db.collection("parties").updateOne({party_code: party_code}, {$push: {song_nominations: songInfo}})
            .then(result => {
                res.status(200).send("Nominated song");
            })
            .catch(result => {
                res.status(400).send("You fucked up");
            })
    }

    static async removeNomination(req, res){
        res.status(200).send("Remove song nomination");
    }

    static async selectRandomUsers(req, res){
        res.status(200).send("Select random users");
    }

    static async emergency(req, res){
        const { party_code, token } = req.body

        const party = await Mongo.db.collection("parties").findOne({party_code: party_code})

        if(party.cops === 5){
            const options = {
                method: 'PUT',
                uri: "https://api.spotify.com/v1/me/player/pause", 
                headers: {'Authorization': 'Bearer ' + token}
            }

            request(options)
                .then(() => {console.log("Paused Song")})
                .catch(() => {console.log("Pause Error")})
        }

        Mongo.db.collection("parties").findOneAndUpdate(
            {'party_code': party_code}, 
            {$inc: {'cops': 1}}
        )
            .then(result => {
                res.status(200).send("Oh shit da cops");
            })
            .catch(result => {
                res.status(400).send("A small piece of me died inside");
            })
    }

    static async getPartyInfo(req, res){

        const { party_code } = req.query

        const party = await Mongo.db.collection("parties").findOne({party_code: party_code})
        
        if(party){
            res.status(200).json(party);
        }else{
            res.status(400).send("Couldn't find that party");
        }
    }
}

const createPartyPlaylist = async (name, user_id, token) => {
    const payload = {name: name, description: `${name} - ${new Date().toDateString()}`, public: false}
    const options = {
        method: 'POST',
        uri: `https://api.spotify.com/v1/users/${user_id}/playlists`, 
        headers: {'Authorization': 'Bearer ' + token},
        body: payload,
        json: true
    }

    return await request(options)
        .then(body => body)
        .catch(err => {
            console.log(err)
        })
}

const startParty = async (playlistId, token) => {
    const context = `spotify:playlist:${playlistId}`
    const options = {
        method: 'PUT',
        uri: "	https://api.spotify.com/v1/me/player/play", 
        headers: {'Authorization': 'Bearer ' + token},
        body: { context_uri: context },
        json: true
    }

    request(options)
        .then(result => {
            //start playing playlist
            //res.status(200).send("Started party");
        })
        .catch(result => {
            //res.status(400).send("You fucked up");
        })
}

export default Party;