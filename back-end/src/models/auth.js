var db = require('../helpers/mongo');
var bcrypt = require("bcrypt")

class Auth {
    async signIn(req, res){
        var username = req.body.username
        var password = req.body.password

        var success = verifyUser(username, password);
        
        if (success) {
            res.status(200).send("You're in!");
        } else {
            res.status(400).send("Wrong username or password D:");
        }
    }

    
    async signUp(req, res){
        res.status(200).send("Sign up");
    }
}

verifyUser = async (username, password) => {
    if(!password || !username) return false;

    var user = await db("boombox").collection("users").findOne({username: username})

    if(!user) return false

    return bcrypt.compareSync(password, user.password);
}

module.exports = new Auth();