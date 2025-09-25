import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import dotenv from "dotenv";
dotenv.config();

const app = express();
const port = process.env.PORT;

//postgres database
const db = new pg.Client({
    user: process.env.PG_USER,
    host: process.env.PG_HOST,
    database: process.env.PG_DATABASE_NAME,
    password: process.env.PG_PASSWORD,
    port: process.env.PG_PORT_NUMBER,
});
db.connect();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

//get route
//post routes

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});