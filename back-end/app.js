var express = require('express');
var app = express();
var expressWs = require('express-ws')(app);
var router = express.Router();
var promise = require('request-promise-native');
 
app.use(function (req, res, next) {
  console.log('middleware');
  req.testing = 'testing';
  return next();
});
 
app.get('/', function(req, res, next){
  console.log('get route', req.testing);
  res.end();
});
 
app.ws('/', function(ws, req) {
  ws.on('message', function(msg) {
    console.log(msg);
  });
  console.log('socket', req.testing);
});

/**
 * Bad boys, bad boys, whatcha gonna do? Whatcha gonna do when they come for you?
 */
app.put('/user', function (req, res) {
  var options = {
    method: 'POST',
    uri: 'https://api.spotify.com/v1/me/player/play',
    body: {
      context_uri: "spotify:album:0zLd8jpRt4m6FWCu81Fb9n",
      offset: {
      position: 0
    },
      position_ms: 0,
    },
    json: true // Automatically stringifies the body to JSON
  };
});

router.get('/playlists', async (req,res) => {
  try {
    var result = await spotifyApi.getUserPlaylists();
    console.log(result.body);
    res.status(200).send(result.body);
  } catch (err) {
    res.status(400).send(err)
  }

});

app.listen(3000);