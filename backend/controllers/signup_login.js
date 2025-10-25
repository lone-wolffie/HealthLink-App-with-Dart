import bcrypt from "bcrypt";
import { db } from "../config/db.js";


const saltRounds = 10;

// signup function
export const signup = async (req, res) => {
    try {
        const { fullname, email, phonenumber, username, password } = req.body;

        if (!fullname || !email || !phonenumber || !username || !password) {
            return res.status(400).json({ message: "All fields are required." });

        }

        const hashedPassword = await bcrypt.hash(password, saltRounds);

        await db.query(
            "INSERT INTO users (fullname, email, phonenumber, username, password) VALUES ($1, $2, $3, $4, $5)",
            [fullname, email, phonenumber, username, hashedPassword]
        );

        res.status(201).json({ message: "Signup successful." });
    } catch (error) {
        console.error("Signup error:", error);
        res.status(500).json({ error: "Signup failed" });
    }
};

// Login function
export const login = async (req, res) => {
    try {
        const { username, password } = req.body;

        const result = await db.query(
            "SELECT * FROM users WHERE username = $1",
            [username]
        );

        if (result.rows.length === 0) {
            return res.status(400).json({ message: "User not found." });
        }

        const user = result.rows[0];
        const passwordMatch = await bcrypt.compare(password, user.password);

        if (!passwordMatch) {
            return res.status(400).json({ message: "Incorrect password! Please try again." })
        }

        res.status(200).json({ message: "Login successful." });

    } catch (error) {
        console.error("Login error:", error);
        res.status(500).json({ error: "Login failed" });
    }
};