import Mongo from '../helpers/mongo';
import Playback from './playback'
import request from 'request-promise-native';


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

    static async checkForSongEndingSoon(party_code, token){
            
        const playerInfoReq = {
            method: 'GET',
            uri: "https://api.spotify.com/v1/me/player", 
            headers: {'Authorization': 'Bearer ' + token},
            json: true
        }

        let partyStarted = false
        let addedSongToPlaylist = false;
        let prevProgress = 0;
        let lastActivity = new Date()

        let progressIntervalId = setInterval(async () => {
            if(addedSongToPlaylist) return

            const party = await Mongo.db.collection("parties").findOne({party_code: party_code})
            let elapsedMins = ((new Date() - lastActivity)/1000)/60
            if(!party){
                clearInterval(progressIntervalId)
                return;
            }
            if(elapsedMins >= 20){
                clearInterval(progressIntervalId)
                Mongo.db.collection("parties").deleteOne({party_code: party_code})
                return
            }
            const songDuration = party.now_playing.duration_ms


            request(playerInfoReq)
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


                if(!partyStarted){
                    Mongo.db.collection("parties").updateOne({party_code: party_code}, {$set: {started: true}})
                    partyStarted = true
                }
                
                const progress = body.progress_ms

                if(progress != prevProgress){
                    lastActivity = new Date()
                }
                prevProgress = progress

                console.log(progress + ' / ' + songDuration)
                

                if(songDuration - progress < 10000){
                    console.log("Last 10 seconds")
                    // add highest rated song to playlist
                    const party = await Mongo.db.collection("parties").findOne({'party_code': party_code})
                    const nominations = party.song_nominations

                    // if no nominations are up
                    if(nominations.length === 0) return

                    nominations.sort(sortByVotes)
                    const nextSong = nominations[0]

                    console.log(`Next song: ${nextSong.name}`)

                    await Playback.addSongToPlaylist(nextSong, party.playlist.id, token)
                    addedSongToPlaylist = true

                    // checking if new song has started playing
                    lastActivity = new Date()
                    let nextIntervalId = setInterval(() => {
                        let elapsedMins = ((new Date() - lastActivity)/1000)/60
                        if(elapsedMins >= 20){
                            clearInterval(nextIntervalId);
                            clearInterval(progressIntervalId)
                            Mongo.db.collection("parties").deleteOne({party_code: party_code})
                            return;
                        }
                        request(playerInfoReq)
                        .then((body) => {
                            // the song has changed, stop waiting
                            if(body.item.id !== party.now_playing.id){
                                console.log("New song started")
                                clearInterval(nextIntervalId);
                                // update party info
                                Mongo.db.collection("parties").updateOne({party_code: party_code}, {$set: {now_playing: nextSong}})
                                Mongo.db.collection("parties").updateOne({party_code: party_code}, {$pull: {song_nominations: {id: nextSong.id}}})

                                addedSongToPlaylist = false
                            }
                        })
                        .catch(err => {console.log(err)})
                    }, 2000)
                }
            })
            .catch(err => {console.log(err)})
        }, 8000)
    }
}

const sortByVotes = (firstEl, secondEl) => {
    if(firstEl.votes < secondEl.votes) return 1;
    if(firstEl.votes > secondEl.votes) return -1;
    return 0
}


export default Vote;