import { Router } from 'express';

import party from '../models/party'
import search from '../models/search'
import vote from '../models/vote'

const routes = Router()

// party routes
routes.delete("/party", party.endParty);
routes.post("/party", party.createParty);

// party attendance
routes.post("/party/attendance", party.joinParty);
routes.delete("/party/attendance", party.leaveParty);

// party info
routes.get("/party/info", party.getPartyInfo);

// nomination routes
routes.post("/party/nomination", party.nominateSong);
routes.delete("/party/nomination", party.removeNomination);

// random routes
routes.get("/party/random", party.selectRandomUsers);

routes.post("/party/cops", party.emergency);

// search routes
routes.get("/search", search.searchForSong);

// voting routes
routes.post("/vote", vote.voteForSong);

export default routes;