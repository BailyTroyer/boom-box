'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _mongo = require('../helpers/mongo');

var _mongo2 = _interopRequireDefault(_mongo);

var _playback = require('./playback');

var _playback2 = _interopRequireDefault(_playback);

var _requestPromiseNative = require('request-promise-native');

var _requestPromiseNative2 = _interopRequireDefault(_requestPromiseNative);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Vote = function () {
    function Vote() {
        _classCallCheck(this, Vote);
    }

    _createClass(Vote, null, [{
        key: 'voteForSong',
        value: async function voteForSong(req, res) {
            var _req$body = req.body,
                party_code = _req$body.party_code,
                user_id = _req$body.user_id,
                song_id = _req$body.song_id;


            var client = (0, _mongo2.default)();
            client.connect(async function (err, cli) {
                var db = cli.db("boom-box");
                db.collection("parties").findOneAndUpdate({ 'party_code': party_code }, { $inc: { 'song_nominations.$[elem].votes': 1 } }, { arrayFilters: [{ 'elem.song_id': song_id }] }).then(function (result) {
                    res.status(200).send("Upvoted");
                }).catch(function (result) {
                    res.status(400).send("A small piece of me died inside");
                });
            });

            client.close();
        }
    }, {
        key: 'checkForSongEndingSoon',
        value: async function checkForSongEndingSoon(party_code, token) {
            var client = (0, _mongo2.default)();
            client.connect(async function (err, cli) {
                var db = cli.db("boom-box");

                var options = {
                    method: 'GET',
                    uri: "https://api.spotify.com/v1/me/player",
                    headers: { 'Authorization': 'Bearer ' + token },
                    json: true
                };

                setInterval(async function () {
                    var party = await db.collection("parties").findOne({ 'party_code': party_code });
                    //console.log(party.now_playing)
                    var songDuration = party.now_playing.duration_ms;

                    (0, _requestPromiseNative2.default)(options).then(async function (body) {
                        // spotify is not open on any of the user's devices
                        if (!body) {
                            return;
                        }
                        // the user hasnt started the party playlist
                        if (body.item.id !== party.now_playing.id) {
                            console.log("Start playing the playlist");
                            return;
                        }

                        var progress = body.progress_ms;

                        console.log(progress + ' / ' + songDuration);

                        if (songDuration - progress < 10000) {
                            console.log("Last 10 seconds");
                            // add highest rated song to playlist
                            var _party = db.collection("parties").findOne({ 'party_code': party_code });
                            var nominations = _party.song_nominations;
                            nominations.sort(sortByVotes);
                            var nextSong = nominations[0];

                            console.log('Next song: ' + nextSong.name);

                            _playback2.default.addSongToPlaylist(nextSong, _party.playlist.id, token);

                            // checking if new song has started playing
                            setInterval(function () {
                                console.log("New song started");
                                (0, _requestPromiseNative2.default)(options).then(function (body) {
                                    // the song has changed, stop waiting
                                    if (body.item.id !== _party.now_playing.id) {
                                        clearInterval();
                                        // update party info
                                        db.collection("parties").updateOne({ party_code: party_code }, { now_playing: nextSong }).then(function (result) {}).catch(function (result) {});
                                    }
                                }).catch(function (err) {});
                            }, 2000);
                        }
                    }).catch(function (err) {
                        console.log(err);
                    });
                }, 10000);
            });

            client.close();
        }
    }]);

    return Vote;
}();

var sortByVotes = function sortByVotes(firstEl, secondEl) {
    if (firstEl.votes < secondEl.votes) return -1;
    if (firstEl.votes > secondEl.votes) return 1;
    return 0;
};

exports.default = Vote;