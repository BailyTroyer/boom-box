import express from 'express';
import bodyParser from 'body-parser';
import routes from './helpers/routes';
import Mongo from './helpers/mongo'

const app = express();
const port = 3000;

Mongo.connect()
    .then(() => {
        app.use(bodyParser.json());
        // support application/x-www-form-urlencoded post data
        app.use(bodyParser.urlencoded({extended: false}));

        // set up request console logging
        const logResponse = (req, res, next) => {
            res.on("finish", () => {
                console.log(`[${new Date().toISOString()}] ${req.ip} - ${req.method} ` +
                `${req.originalUrl} - ${res.statusCode} ${res.statusMessage}`);
            });
            next();
        };

        app.use(logResponse);
        app.use('/', routes)

        app.listen(port);

        console.log(`Running on localhost:${port}`)
    })


