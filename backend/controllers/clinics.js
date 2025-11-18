import { db } from "../config/db.js";

// get all clinics
export const getAllClinics = async (req, res) => {
    try {
        const result = await db.query(
            "SELECT * FROM clinics ORDER BY name ASC"
        );
        res.status(200).json(result.rows);
    } catch (error) {
        console.error("Error fetching clinics:", error);
        res.status(500).json({ error: "Failed to fetch all clinics" });
    }
};

// add a clinic
export const addClinic = async (req, res) => {
    try {
        const { name, address, phonenumber, email, latitude, longitude, services, operating_hours } = req.body;

        if (!name || !address || !phonenumber || !email) {
            return res.status(400).json({ message: "Clinic name, address, contact and email are required." });
        }

        await db.query(
            `INSERT INTO clinics (name, address, phonenumber, email, latitude, longitude, services, operating_hours) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
            [name, address, phonenumber, email, latitude, longitude, services, operating_hours]
        );
        res.status(200).json({ message: "Clinic added successfully." });
    } catch (error) {
        console.error("Error adding clinic:", error);
        res.status(500).json({ error: "Failed to add clinic." });
    }
};



