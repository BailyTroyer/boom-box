'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _mongo = require('../helpers/mongo');

var _mongo2 = _interopRequireDefault(_mongo);

var _playback = require('./playback');

var _playback2 = _interopRequireDefault(_playback);

var _vote = require('./vote');

var _vote2 = _interopRequireDefault(_vote);

var _requestPromiseNative = require('request-promise-native');

var _requestPromiseNative2 = _interopRequireDefault(_requestPromiseNative);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Party = function () {
    function Party() {
        _classCallCheck(this, Party);
    }

    _createClass(Party, null, [{
        key: 'joinParty',
        value: async function joinParty(req, res) {
            var _req$body = req.body,
                party_code = _req$body.party_code,
                user_id = _req$body.user_id;


            var client = (0, _mongo2.default)();
            client.connect(function (err, cli) {
                var db = cli.db("boom-box");
                db.collection("parties").updateOne({ party_code: party_code }, { $push: { guests: user_id } }).then(function (result) {
                    // add party to user document
                    db.collection("users").updateOne({ user_id: user_id }, { $set: { party_code: party_code, host: false } }, { upsert: true }).then(function (result) {
                        res.status(200).send("You're in!");
                    }).catch(function (result) {
                        res.status(400).send("You fucked up");
                    });
                }).catch(function (result) {
                    res.status(400).send("You fucked up");
                });
            });
            client.close();
        }
    }, {
        key: 'leaveParty',
        value: async function leaveParty(req, res) {
            var user_id = req.body.user_id;


            var client = (0, _mongo2.default)();
            client.connect(function (err, cli) {
                var db = cli.db("boom-box");

                db.collection("users").updateOne({ user_id: user_id }, { party_code: null, host: false }).then(function (result) {
                    res.status(200).send("You're out!");
                }).catch(function (result) {
                    res.status(400).send("You fucked up");
                });
            });

            client.close();
        }
    }, {
        key: 'endParty',
        value: async function endParty(req, res) {
            var party_code = req.body.party_code;


            var client = (0, _mongo2.default)();
            client.connect(async function (err, cli) {
                var db = cli.db("boom-box");

                var party = await db.collection("parties").findOne({ party_code: party_code });

                for (var guest_id in party.guests) {
                    db.collection("users").updateOne({ user_id: guest_id }, { party_code: null });
                }

                db.collection("parties").deleteOne({ party_code: party_code }).then(function (result) {
                    res.status(200).send("Ended party");
                }).catch(function (result) {
                    res.status(400).send("You fucked up");
                });
            });
            client.close();
        }
    }, {
        key: 'createParty',
        value: async function createParty(req, res) {
            var _req$body2 = req.body,
                party_code = _req$body2.party_code,
                size = _req$body2.size,
                name = _req$body2.name,
                token = _req$body2.token,
                starter_song = _req$body2.starter_song,
                user_id = _req$body2.user_id;


            var songInfo = await _playback2.default.getSongInfo(starter_song, token);
            var playlist = await createPartyPlaylist(name, user_id, token);

            await _playback2.default.addSongToPlaylist(songInfo, playlist.id, token);

            var client = (0, _mongo2.default)();
            client.connect(function (err, cli) {
                var db = cli.db("boom-box");

                db.collection("parties").insertOne({
                    now_playing: songInfo,
                    playlist: playlist,
                    party_code: party_code,
                    size: size,
                    name: name,
                    token: token,
                    song_nominations: [],
                    guests: [],
                    cops: 0
                }).then(function (result) {
                    //start playing playlist
                    startParty(playlist.id, token);
                    res.status(200).send("Created party");
                }).catch(function (result) {
                    console.log(result);
                    res.status(400).send("You fucked up");
                });
            });
            client.close();

            // runs for the life of the party
            _vote2.default.checkForSongEndingSoon(party_code, token);
        }
    }, {
        key: 'nominateSong',
        value: async function nominateSong(req, res) {
            var _req$body3 = req.body,
                party_code = _req$body3.party_code,
                song_url = _req$body3.song_url,
                token = _req$body3.token;


            var songInfo = await _playback2.default.getSongInfo(song_url, token);
            songInfo.votes = 0;

            var client = (0, _mongo2.default)();
            client.connect(async function (err, cli) {
                var db = cli.db("boom-box");

                var party = await db.collection("parties").findOne({ party_code: party_code });

                // if the dong is already in the nominations
                if (party.song_nominations.find(function (song) {
                    return song.id === songInfo.id;
                })) {
                    res.status(200).send("Song already nominated");
                    return;
                }

                db.collection("parties").updateOne({ party_code: party_code }, { $push: { song_nominations: songInfo } }).then(function (result) {
                    res.status(200).send("Nominated song");
                }).catch(function (result) {
                    res.status(400).send("You fucked up");
                });
            });
            client.close();
        }
    }, {
        key: 'removeNomination',
        value: async function removeNomination(req, res) {
            res.status(200).send("Remove song nomination");
        }
    }, {
        key: 'selectRandomUsers',
        value: async function selectRandomUsers(req, res) {
            res.status(200).send("Select random users");
        }
    }, {
        key: 'emergency',
        value: async function emergency(req, res) {
            var _req$body4 = req.body,
                party_code = _req$body4.party_code,
                token = _req$body4.token;


            var client = (0, _mongo2.default)();
            client.connect(async function (err, cli) {
                var db = cli.db("boom-box");

                var party = await db.collection("parties").findOne({ party_code: party_code });

                if (party.cops === 5) {
                    var options = {
                        method: 'PUT',
                        uri: "https://api.spotify.com/v1/me/player/pause",
                        headers: { 'Authorization': 'Bearer ' + token }
                    };

                    (0, _requestPromiseNative2.default)(options).then(function () {
                        console.log("Paused Song");
                    }).catch(function () {
                        console.log("Pause Error");
                    });
                }

                db.collection("parties").findOneAndUpdate({ 'party_code': party_code }, { $inc: { 'cops': 1 } }).then(function (result) {
                    res.status(200).send("Oh shit da cops");
                }).catch(function (result) {
                    res.status(400).send("A small piece of me died inside");
                });
            });

            client.close();
        }
    }, {
        key: 'getPartyInfo',
        value: async function getPartyInfo(req, res) {
            var party_code = req.query.party_code;


            var client = (0, _mongo2.default)();
            client.connect(async function (err, cli) {
                var db = cli.db("boom-box");

                var party = await db.collection("parties").findOne({ party_code: party_code });

                if (party) {
                    res.status(200).json(party);
                } else {
                    res.status(400).send("You fucked up");
                }
            });
            client.close();
        }
    }]);

    return Party;
}();

var createPartyPlaylist = async function createPartyPlaylist(name, user_id, token) {
    var payload = { name: name, description: name + ' - ' + new Date().toDateString(), public: false };
    var options = {
        method: 'POST',
        uri: 'https://api.spotify.com/v1/users/' + user_id + '/playlists',
        headers: { 'Authorization': 'Bearer ' + token },
        body: payload,
        json: true
    };

    return await (0, _requestPromiseNative2.default)(options).then(function (body) {
        return body;
    }).catch(function (err) {
        console.log(err);
    });
};

var startParty = async function startParty(playlistId, token) {
    var context = 'spotify:playlist:' + playlistId;
    var options = {
        method: 'PUT',
        uri: "	https://api.spotify.com/v1/me/player/play",
        headers: { 'Authorization': 'Bearer ' + token },
        body: { context_uri: context },
        json: true
    };

    (0, _requestPromiseNative2.default)(options).then(function (result) {
        //start playing playlist
        //res.status(200).send("Started party");
    }).catch(function (result) {
        //res.status(400).send("You fucked up");
    });
};

exports.default = Party;