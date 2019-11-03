var db = require('../helpers/mongo');
var bcrypt = require("bcrypt")

class Auth {
    async signIn(req, res){
        res.status(200).send("Sign in");
    }

    async signUp(req, res){
        res.status(200).send("Sign up");
    }
}

module.exports = new Auth();