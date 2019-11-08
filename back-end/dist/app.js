'use strict';

var _express = require('express');

var _express2 = _interopRequireDefault(_express);

var _bodyParser = require('body-parser');

var _bodyParser2 = _interopRequireDefault(_bodyParser);

var _routes = require('./helpers/routes');

var _routes2 = _interopRequireDefault(_routes);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var app = (0, _express2.default)();
var port = 3000;

app.use(_bodyParser2.default.json());
// support application/x-www-form-urlencoded post data
app.use(_bodyParser2.default.urlencoded({ extended: false }));

// set up request console logging
var logResponse = function logResponse(req, res, next) {
    res.on("finish", function () {
        console.log('[' + new Date().toISOString() + '] ' + req.ip + ' - ' + req.method + ' ' + (req.originalUrl + ' - ' + res.statusCode + ' ' + res.statusMessage));
    });
    next();
};

app.use(logResponse);
app.use('/', _routes2.default);

app.listen(port);

console.log('Running on localhost:' + port);