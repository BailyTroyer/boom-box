var express = require('express');
var bodyParser = require('body-parser');
var routes = require('./helpers/routes');

var app = express();

app.use(bodyParser.json());
// support application/x-www-form-urlencoded post data
app.use(bodyParser.urlencoded({extended: false}));

// set up request console logging
logResponse = (req, res, next) => {
    res.on("finish", () => {
        console.log(`[${new Date().toISOString()}] ${req.ip} - ${req.method} ` +
        `${req.originalUrl} - ${res.statusCode} ${res.statusMessage}`);
    });
    next();
};

app.use(logResponse);
app.use('/', routes)

app.listen(3000);