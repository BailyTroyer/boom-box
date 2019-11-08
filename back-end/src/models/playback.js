import newClient from '../helpers/mongo';
import request from 'request-promise-native';


class Playback {
    static async pauseMusic(req, res){
        const { party_code } = req.body

        const client = newClient();
        client.connect(async (err, cli) => { 
            const db =  cli.db("boom-box")
            const party = await db.collection("parties").findOne({'party_code': party_code})
            
            const options = {
                uri: "https://api.spotify.com/v1/me/player/pause", 
                headers: {'Authorization': 'Bearer ' + party.token}
            }

            await request(options)
                .then(result => {
                    res.status(200).send("Paused");
                })
                .catch(result => {
                    res.status(400).send("Something fucked up");
                })
        });

        client.close()
    }

    static async getSongInfo(songUrl, token){
        const songId = songUrl.replace("https://open.spotify.com/track/" , "")

        const options = {
            uri: `https://api.spotify.com/v1/tracks/${songId}`,
            headers: {'Authorization': 'Bearer ' + token},
        }

        const songInfo = await request(options)
            .then(body => {
                return body
            })
            .catch(err => {
                return null
            })
        
        if(songInfo) return JSON.parse(songInfo);  
    }

    static async addSongToPlaylist(song, playlistId, token){

        const songUri = song.uri

        const options = {
            method: 'POST',
            uri: `https://api.spotify.com/v1/playlists/${playlistId}/tracks?uris=${songUri}`, 
            headers: {'Authorization': 'Bearer ' + token}
        }

        request(options)
            .then(body => {})
            .catch(err => {console.log(err.message)})
    }
}

export default Playback;