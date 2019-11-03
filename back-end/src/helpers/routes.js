var router = require('express').Router();

// var auth = require('../models/auth')
var party = require('../models/party')
var search = require('../models/search')
var vote = require('../models/vote')

// // auth routes
// router.get("/auth", auth.signIn);
// router.post("/auth", auth.signUp);

// party routes

router.delete("/party", party.endParty);
router.post("/party", party.createParty);

// party attendance
router.post("/party/attendance", party.joinParty);
router.delete("/party/attendance", party.leaveParty);

// party info
router.get("/party/info", party.getPartyInfo);

// nomination routes
router.post("/party/nomination", party.nominateSong);
router.delete("/party/nomination", party.removeNomination);

// random routes
router.get("/party/random", party.selectRandomUsers);

router.post("/party/cops", party.emergency);

// search routes
router.get("/search", search.searchForSong);

// voting routes
router.post("/vote", vote.voteForSong);

module.exports = router;