const MongoClient = require('mongodb').MongoClient;
var express = require('express');
var bodyParser = require('body-parser');
var routes = require('../helpers/routes');


const uri = "mongodb+srv://db_user:Password123@cluster0-alpf4.gcp.mongodb.net/test?retryWrites=true&w=majority";

const newClient = () => {
    return new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });
}

module.exports = newClient;