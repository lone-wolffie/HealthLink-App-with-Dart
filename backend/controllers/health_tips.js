import { db } from "../config/db.js";

// get all the health tips
export const getAllHealthTips = async (req, res) => {
    try {
        const result = await db.query(
            "SELECT * FROM health_tips"
        );
        res.status(200).json(result.rows);
    } catch (error) {
        console.error("Error fetching all the health tips:", error);
        res.status(500).json({ error: "Failed to load all the health tips" });
    }
};

// add a health tip
export const addHealthTip = async (req, res) => {
    try {
        const { title, content } = req.body;

        if (!title || !content) {
            return res.status(400).json({ message: "Title and content are required." });
        }

        await db.query(
            "INSERT INTO health_tips (title, content) VALUES ($1, $2)",
            [title, content]
        );

        res.status(200).json({ message: "Health tip added sucessfully." });
    } catch (error) {
        console.error("Error adding the health tip");
        res.status(500).json({ error: "Failed to add the health tip" });
    }
};

// delete a health tip using its id
export const deleteHealthTip = async (req, res) => {
    try {
        const { id } = req.params;

        // delete a tip and return  the deleted row
        const result = await db.query(
            "DELETE FROM health_tips WHERE id = $1 RETURNING *",
            [id]
        );

        if (result.rowCount === 0) {
            return res.status(404).json({ message: "Health tip not found." });
        }

        res.status(200).json({ message: "Health tip deleted successfully" });
    } catch (error) {
        console.error("Error deleting the health tip:", error);
        res.status(500).json({ error: "Failed to delete the health tip" });
    }
};