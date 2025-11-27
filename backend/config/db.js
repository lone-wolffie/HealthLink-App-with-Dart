import pg from "pg";
import dotenv from "dotenv";

dotenv.config();

// Use Render's DATABASE_URL
export const db = new pg.Client({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false,
  },
});

db.connect()
  .then(() => console.log("Database connected successfully"))
  .catch((error) => console.error("Database connection error:", error));
