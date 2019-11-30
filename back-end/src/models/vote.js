import Mongo from '../helpers/mongo';
import Playback from './playback'
import request from 'request-promise-native';
import Party from './party'


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
        let waitingForNextSong = false;
        let advertising = false
        let nextIntervalId = null

        let progressIntervalId = setInterval(async () => {
            // check that party exists
            const party = await Mongo.db.collection("parties").findOne({party_code: party_code})
            if(!party){
                console.log("No Party in DB... ending loop")
                clearInterval(progressIntervalId)
                clearInterval(nextIntervalId)
                return;
            }

            Mongo.db.collection("parties").updateOne({party_code: party_code}, {$set: {last_active: new Date()}})
            if(waitingForNextSong) return

            let totalMins = ((new Date() - party.start_time)/1000)/60


            if(totalMins >= 120){
                clearInterval(progressIntervalId)
                clearInterval(nextIntervalId)
                Mongo.db.collection("parties").deleteOne({party_code: party_code})
                console.log("PARTY OVER")
                return
            }

            const songDuration = party.now_playing.duration_ms

            request(playerInfoReq)
            .then(async (body) => {
                // spotify is not active on any of the user's devices
                if(!body){
                    console.log("Cmon, at least open Spotify")
                    return
                }
                // the user hasnt started the party playlist
                if(!body.item && !advertising){
                    console.log("Probably playing ad...")
                    Mongo.db.collection("parties").updateOne({party_code: party_code}, {$set: {playing_ad: true}})
                    advertising = true
                    return
                }
                if(!body.context || body.item.id !== party.now_playing.id || body.context.href !== party.playlist.href){
                    console.log(`Start playing - ${party.now_playing.name} - in the "${party.name}" playlist`)
                    if(party.started){
                        Mongo.db.collection("parties").updateOne({party_code: party_code}, {$set: {started: false}})
                        partyStarted = false
                    }
                    return
                }
                if(!partyStarted){
                    Mongo.db.collection("parties").updateOne({party_code: party_code}, {$set: {started: true}})
                    partyStarted = true
                }

                /* the user has started the playlist || an ad has stopped playing */


                if(advertising){
                    Mongo.db.collection("parties").updateOne({party_code: party_code}, {$set: {playing_ad: false}})
                    advertising = false
                }
                
                const progress = body.progress_ms
                

                console.log(progress + ' / ' + songDuration)
                

                if(songDuration - progress < 10000){
                    console.log("Last 10 seconds")
                    
                    const party = await Mongo.db.collection("parties").findOne({'party_code': party_code})

                    if(!party){
                        console.log("No Party in DB... ending loop")
                        clearInterval(progressIntervalId)
                        clearInterval(nextIntervalId)
                        return;
                    }


                    // add highest rated song to playlist
                    const nominations = party.song_nominations

                    nominations.sort(sortByVotes)
                    const nextSong = nominations[0] || party.fallback
                    console.log(`Next song: ${nextSong.name}`)

                    await Playback.addSongToPlaylist(nextSong, party.playlist.id, token)
                    waitingForNextSong = true

                    // checking if new song has started playing
                    nextIntervalId = setInterval(() => {
                        request(playerInfoReq)
                        .then((body) => {
                            
                            if(!body){return} // spotify inactive

                            if(!body.item ){ // an ad is playing
                                if(!advertising){
                                    Mongo.db.collection("parties").updateOne({party_code: party_code}, {$set: {playing_ad: true}})
                                    advertising = true
                                }
                                return
                            }
                            if(body.item.id === nextSong.id){ // the next song has started
                                console.log("Next song started")

                                clearInterval(nextIntervalId);

                                if(advertising){ // ad is no longer playing
                                    Mongo.db.collection("parties").updateOne({party_code: party_code}, {$set: {playing_ad: false}})
                                    advertising = false
                                }

                                // update party info
                                Mongo.db.collection("parties").updateOne({party_code: party_code}, {$set: {now_playing: nextSong}})
                                Mongo.db.collection("parties").updateOne({party_code: party_code}, {$pull: {song_nominations: {id: nextSong.id}}})

                                Party.setFallbackNomination(party_code, nextSong.id, token)

                                waitingForNextSong = false
                            }
                        })
                        .catch(err => {
                            // usually happens when access token expires
                            Mongo.db.collection("parties").deleteOne({party_code: party_code})
                            console.log(err)
                            clearInterval(nextIntervalId);
                            clearInterval(progressIntervalId);

                        })
                    }, 2000)
                }
            })
            .catch(err => {
                // usually happens when access token expires
                Mongo.db.collection("parties").deleteOne({party_code: party_code})
                console.log(err)
                clearInterval(nextIntervalId);
                clearInterval(progressIntervalId);
            })
        }, 8000)
    }
}

const sortByVotes = (firstEl, secondEl) => {
    if(firstEl.votes < secondEl.votes) return 1;
    if(firstEl.votes > secondEl.votes) return -1;
    return 0
}


export default Vote;