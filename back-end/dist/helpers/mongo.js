"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _mongodb = require("mongodb");

var uri = "mongodb+srv://db_user:Password123@cluster0-alpf4.gcp.mongodb.net/test?retryWrites=true&w=majority";

var newClient = function newClient() {
    return new _mongodb.MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });
};

exports.default = newClient;