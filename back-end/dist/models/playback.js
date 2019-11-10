'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _mongo = require('../helpers/mongo');

var _mongo2 = _interopRequireDefault(_mongo);

var _requestPromiseNative = require('request-promise-native');

var _requestPromiseNative2 = _interopRequireDefault(_requestPromiseNative);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Playback = function () {
    function Playback() {
        _classCallCheck(this, Playback);
    }

    _createClass(Playback, null, [{
        key: 'pauseMusic',
        value: async function pauseMusic(req, res) {
            var party_code = req.body.party_code;


            var client = (0, _mongo2.default)();
            client.connect(async function (err, cli) {
                var db = cli.db("boom-box");
                var party = await db.collection("parties").findOne({ 'party_code': party_code });

                var options = {
                    uri: "https://api.spotify.com/v1/me/player/pause",
                    headers: { 'Authorization': 'Bearer ' + party.token }
                };

                await (0, _requestPromiseNative2.default)(options).then(function (result) {
                    res.status(200).send("Paused");
                }).catch(function (result) {
                    res.status(400).send("Something fucked up");
                });
            });

            client.close();
        }
    }, {
        key: 'getSongInfo',
        value: async function getSongInfo(songUrl, token) {
            var songId = songUrl.replace("https://open.spotify.com/track/", "");

            var options = {
                uri: 'https://api.spotify.com/v1/tracks/' + songId,
                headers: { 'Authorization': 'Bearer ' + token }
            };

            var songInfo = await (0, _requestPromiseNative2.default)(options).then(function (body) {
                return body;
            }).catch(function (err) {
                console.log(err);
                return null;
            });

            if (songInfo) return JSON.parse(songInfo);
        }
    }, {
        key: 'addSongToPlaylist',
        value: async function addSongToPlaylist(song, playlistId, token) {

            var songUri = song.uri;

            var options = {
                method: 'POST',
                uri: 'https://api.spotify.com/v1/playlists/' + playlistId + '/tracks?uris=' + songUri,
                headers: { 'Authorization': 'Bearer ' + token }
            };

            (0, _requestPromiseNative2.default)(options).then(function (body) {}).catch(function (err) {
                console.log(err.message);
            });
        }
    }]);

    return Playback;
}();

exports.default = Playback;