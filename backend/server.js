import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import pg from "pg";
import bcrypt from "bcrypt";
import dotenv from "dotenv";
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;
const saltRounds = 10;

//postgres database
const db = new pg.Client({
    user: process.env.PG_USER,
    host: process.env.PG_HOST,
    database: process.env.PG_DATABASE_NAME,
    password: process.env.PG_PASSWORD,
    port: process.env.PG_PORT_NUMBER,
});
db.connect()
    .then(() => console.log("Database connected successfully,"))
    .catch((error) => console.error("Database connection error:", error));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

// Hashing password function
async function hashPasswords(originalPassword) { 
    try {
        const hash = await bcrypt.hash(originalPassword, saltRounds);
        console.log(hash);
        return hash;

    } catch (err){
        console.log(err);
    }
};
hashPasswords("");

//get route
//post routes

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});