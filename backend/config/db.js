import pg from "pg";
import dotenv from "dotenv";
dotenv.config();

//postgres database
export const db = new pg.Client({
    user: process.env.PG_USER,
    host: process.env.PG_HOST,
    database: process.env.PG_DATABASE_NAME,
    password: process.env.PG_PASSWORD,
    port: process.env.PG_PORT_NUMBER,
});

db.connect()
    .then(() => console.log("Database connected successfully,"))
    .catch((error) => console.error("Database connection error:", error));
