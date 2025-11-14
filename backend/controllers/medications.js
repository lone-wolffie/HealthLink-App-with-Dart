import { db } from "../config/db.js";

// creating a new medication
export const createMedication = async (req, res) => {
    try {
        const { user_id, name, dose, times, notes } = req.body;
        
        if (!user_id || !name || !dose || !times || !Array.isArray(times) || times.length === 0) {
            return res.status(400).json({error: "user id, name, dose and dosage time are required"});
        }

        await db.query(
            `INSERT INTO medications (user_id, name, dose, times, notes)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING *
            `,
            [user_id, name, dose, times, notes || null]
        );

        return res.status(200).json({ message: "Medication added successfully" });
    } catch (error) {
        console.error("Error creating the medication:", error );
        return res.status(500).json({ error: "Failed to add medication" });
    }
};

// get all medications for a specific user
export const getUserMedication = async (req, res) => {
    try {
       const { user_id } = req.params;
       
       if (!user_id) {
        return res.status(400).json({ message: "User id is required" });
       }

       const result = await db.query(
        "SELECT * FROM medications WHERE user_id = $1 ORDER BY created_at DESC",
        [user_id]
       );

       return res.status(200).json(result.rows);
    } catch (error) {
        console.error("Error getting all the medications:", error );
        return res.status(500).json({ error: "Failed to get all the medications" });
    }
};

// get a single medication
export const getMedication = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
        "SELECT * FROM medications WHERE id = $1", 
        [id]
    );

    if (result.rowCount === 0) {
        return res.status(404).json({ error: "Medication not found" });
    }

    return res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error("Error geting the mentioned medication:'", error);
    return res.status(500).json({ error: "Failed to get the mentioned medication" });
  }
};

// delete specific medication
export const deleteMedication = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
        "DELETE FROM medications WHERE id = $1 RETURNING *", 
        [id]
    );

    if (result.rowCount === 0) {
        return res.status(404).json({ error: "Medication not found" });
    }

    return res.status(200).json({ 
        message: "Medication deleted successfully", 
        medication: result.rows[0] 
    });
  } catch (error) {
    console.error("Error deleting medication", error);
    return res.status(500).json({ error: "Failed to delete medication" });
  }
};