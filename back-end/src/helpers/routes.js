var router = require('express').Router();

var auth = require('../models/auth')
var party = require('../models/party')
var search = require('../models/search')
var vote = require('../models/vote')

// auth routes
router.get("/auth", auth.signIn);
router.post("/auth", auth.signUp);

// party routes
router.get("/party", party.joinParty);
router.delete("/party", party.endParty);
router.post("/party", party.createParty);

// nomination routes
router.post("/party/nomination", party.nominateSong);
router.delete("/party/nomination", party.removeNomination);

// search routes
router.get("/search", search.searchForSong);

// voting routes
router.post("/vote", vote.voteForSong);

module.exports = router;