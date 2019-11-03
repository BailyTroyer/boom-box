var newClient = require('../helpers/mongo');
var request = require('request-promise-native');

class Playback {
    async pauseMusic(req, res){
        var { party_code } = req.body

        const client = newClient();
        client.connect(async (err, cli) => { 
            const db =  cli.db("boom-box")
            const party = await db.collection("parties").findOne({'party_code': party_code})
            
            const options = {
                uri: "https://api.spotify.com/v1/me/player/pause", 
                headers: {'Authorization': 'Bearer ' + party.token}
            }

            request(options)
                .then(result => {
                    res.status(200).send("Paused");
                })
                .catch(result => {
                    res.status(400).send("Something fucked up");
                })
        });

        client.close()
    }

    async getSongInfo(songUrl, token){
        const songId = songUrl.replace("https://open.spotify.com/track/" , "")

        const options = {
            uri: `https://api.spotify.com/v1/tracks/${songId}`,
            headers: {'Authorization': 'Bearer ' + token}
        }

        const songInfo = await request(options)
            .then(body => {
                return body
            })
            .catch(err => {
                return err
            })

        return songInfo;
    }

    async addSongToPlaylist(song, playlistId, token){
        // https://developer.spotify.com/console/post-playlists
        // {
        //     "name": "New Playlist",
        //     "description": "New playlist description",
        //     "public": false
        // }

        const songUri = JSON.parse(song).uri

        console.log(JSON.parse(song))

        //songUri = "spotify:track:4iV5W9uYEdYUVa79Axb7Rh"
        //playlistId = "5DejKuy4jZsSUuqpKRX4vi"

        const options = {
            uri: `https://api.spotify.com/v1/playlists/${playlistId}/tracks`, 
            headers: {'Authorization': 'Bearer ' + token},
            body: {uris: [songUri]},
            json: true
        }

        request(options)
        .then((body) => {
            console.log("BODY------------------------------------")
            console.log(body)
        })
        .catch((err) => {
            console.log(err)
        })
    }
}

module.exports = new Playback();