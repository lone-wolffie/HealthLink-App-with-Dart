import { db } from "../config/db.js";

// get all symptoms for a specific user 
export const getSymptomHistory = async (req, res) => {
    try {
        const { user_id } = req.params;

        const result = await db.query(
            "SELECT * FROM symptoms_checker WHERE user_id = $1 ORDER BY created_at DESC",
            [user_id]
        );

        res.status(200).json(result.rows);
    } catch (error) {
        console.error("Error getting symptoms history:", error);
        res.status(500).json({ message: "Failed to load symptoms history" });
    }
};

// add a new symptom for a user
export const addSymptom = async (req, res) => {
    try {
        const { user_id, symptom, severity, notes } = req.body;

        if (!user_id || !symptom || !severity) {
            return res.status(400).json({ message: "All fields are required" });
        }

        await db.query(
            "INSERT INTO symptoms_checker (user_id, symptom, severity, notes) VALUES ($1, $2, $3, $4)",
            [user_id, symptom, severity, notes || ""]
        );

        res.status(201).json({ message: "Symptom added successfully" });
    } catch (error) {
        console.error("Error adding new symptom:", error);
        res.status(500).json({ message: "Failed to add a new symptom" });
    }
};

// delete a symptom using its id
export const deleteSymptom = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await db.query(
            "DELETE FROM symptoms_checker WHERE id = $1 RETURNING *",
            [id]
        );

        if (result.rowCount === 0) {
            return res.status(404).json({ message: "No symptom found" });
        }

        res.status(200).json({ message: "Symptom deleted successfully" });
    } catch (error) {
        console.error("Error deleting the symptom:", error);
        res.status(500).json({ message: "Failed to delete the symptom" });
    }
};