import newClient from '../helpers/mongo';
import Playback from './playback'
import request from 'request-promise-native';


class Vote {
    static async voteForSong(req, res){
        const { party_code, user_id, song_id, vote } = req.body

        const client = newClient();
        client.connect(async (err, cli) => { 
            const db =  cli.db("boom-box");
            db.collection("parties").findOneAndUpdate(
                {'party_code': party_code}, 
                {$inc: {'song_nominations.$[elem].votes': vote ? 1 : -1}},
                {arrayFilters: [{'elem.id': song_id }]})

            .then(result => {
                res.status(200).send("Upvoted");
            })
            .catch(result => {
                res.status(400).send("A small piece of me died inside");
            })
        });

        client.close();
    }

    static async checkForSongEndingSoon(party_code, token){
        
        const client = newClient();
        client.connect(async (err, cli) => { 
            const db =  cli.db("boom-box")
            

            const options = {
                method: 'GET',
                uri: "https://api.spotify.com/v1/me/player", 
                headers: {'Authorization': 'Bearer ' + token},
                json: true
            }

            let progressIntervalId = setInterval(async () => {
                const party = await db.collection("parties").findOne({'party_code': party_code})
                if(!party){
                    console.log("PARTY OVER")
                    clearInterval(progressIntervalId)
                    return;
                }
                const songDuration = party.now_playing.duration_ms


                request(options)
                .then(async (body) => {
                    // spotify is not open on any of the user's devices
                    if(!body){
                        console.log("Cmon, at least open Spotify")
                        return
                    }
                    // the user hasnt started the party playlist
                    if(body.item.id !== party.now_playing.id || body.context.href !== party.playlist.href){
                        console.log(`Start playing - ${party.now_playing.name} - in the "${party.name}" playlist`)
                        return
                    }
                    
                    const progress = body.progress_ms

                    console.log(progress + ' / ' + songDuration)
                    let addedSongToPlaylist = false;

                    if(songDuration - progress < 10000 && !addedSongToPlaylist){
                        console.log("Last 10 seconds")
                        // add highest rated song to playlist
                        const party = await db.collection("parties").findOne({'party_code': party_code})
                        const nominations = party.song_nominations

                        // if no nominations are up
                        if(nominations.length === 0) return

                        nominations.sort(sortByVotes)
                        const nextSong = nominations[0]

                        console.log(`Next song: ${nextSong.name}`)

                        await Playback.addSongToPlaylist(nextSong, party.playlist.id, token)
                        addedSongToPlaylist = true

                        // checking if new song has started playing
                        let nextIntervalId = setInterval(() => {
                            
                            request(options)
                            .then((body) => {
                                // the song has changed, stop waiting
                                if(body.item.id !== party.now_playing.id){
                                    console.log("New song started")
                                    clearInterval(nextIntervalId);
                                    // update party info
                                    db.collection("parties").updateOne({party_code: party_code}, {$set: {now_playing: nextSong}})
                                    db.collection("parties").updateOne({party_code: party_code}, {$pull: {song_nominations: {id: nextSong.id}}})

                                    addedSongToPlaylist = false
                                }
                            })
                            .catch(err => {})
                        }, 2000)
                    }
                })
                .catch(err => {
                    console.log(err)
                })
            }, 8000)
        })
        client.close()
    }
}

const sortByVotes = (firstEl, secondEl) => {
    if(firstEl.votes < secondEl.votes) return 1;
    if(firstEl.votes > secondEl.votes) return -1;
    return 0
}


export default Vote;