import { db } from "../config/db.js";

// get all clinics
export const getAllClinics = async (req, res) => {
    try {
        await db.query(
            "SELECT * FROM clinics ORDER BY name ASC"
        );
        res.status(200).json(result.rows);
    } catch (error) {
        console.error("Error fetching clinics:", error);
        res.status(500).json({ message: "Failed to fetch all clinics" });
    }
};

// add a clinic
export const addClinic = async (req, res) => {
    try {
        const { name, address, phonenumber, email } = req.body;
        if (!name || !address || !phonenumber || !email) {
            return res.status(400).json({ message: "Clinic name, address, contact and email are required." });
        }

        await db.query(
            "INSERT INTO clinics (name, address, phonenumber, email) VALUES ($1, $2, $3, $4)",
            [name, address, phonenumber, email]
        );
        res.status(201).json({ message: "Clinic added successfully." });
    } catch (error) {
        console.error("Error adding clinic:", error);
        res.status(500).json({ error: "Failed to add clinic." });
    }
};



