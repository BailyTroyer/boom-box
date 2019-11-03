const MongoClient = require('mongodb').MongoClient;
var express = require('express');
var bodyParser = require('body-parser');
var routes = require('../helpers/routes');


const uri = "mongodb+srv://db_user:Password123@cluster0-alpf4.gcp.mongodb.net/test?retryWrites=true&w=majority";

const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });

var db;

client.connect((err, client) => {    
    if (err) return "Please bro, cmon bro"   
});

module.exports = client;