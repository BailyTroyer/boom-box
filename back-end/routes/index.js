var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.send('https://cse.buffalo.edu/~kds/interests.html');
});

module.exports = router;
