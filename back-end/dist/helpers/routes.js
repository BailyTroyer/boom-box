'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _express = require('express');

var _party = require('../models/party');

var _party2 = _interopRequireDefault(_party);

var _search = require('../models/search');

var _search2 = _interopRequireDefault(_search);

var _vote = require('../models/vote');

var _vote2 = _interopRequireDefault(_vote);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var routes = (0, _express.Router)();

// party routes
routes.delete("/party", _party2.default.endParty);
routes.post("/party", _party2.default.createParty);

// party attendance
routes.post("/party/attendance", _party2.default.joinParty);
routes.delete("/party/attendance", _party2.default.leaveParty);

// party info
routes.get("/party/info", _party2.default.getPartyInfo);

// nomination routes
routes.post("/party/nomination", _party2.default.nominateSong);
routes.delete("/party/nomination", _party2.default.removeNomination);

// random routes
routes.get("/party/random", _party2.default.selectRandomUsers);

routes.post("/party/cops", _party2.default.emergency);

// search routes
routes.get("/search", _search2.default.searchForSong);

// voting routes
routes.post("/vote", _vote2.default.voteForSong);

exports.default = routes;