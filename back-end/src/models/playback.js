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
            .then((err, response, body) => {
                return body
            })
            .catch(err => {
                console.log(err)
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

        const songUri = song.uri

        const options = {
            uri: `https://api.spotify.com/v1/playlists/${playlistId}/tracks`, 
            headers: {'Authorization': 'Bearer ' + token},
            body: {uris: [songUri]}
        }

        request(options)
        .then((err, res, body) => {})
        .catch(err => {
            console.log(err)
        })
    }
}

module.exports = new Playback();