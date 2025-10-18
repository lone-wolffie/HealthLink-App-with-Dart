import { db } from "../config/db.js";

// get all clinics
export const getAllClinics = async (req, res) => {
    try {
        await db.query(
            "SELECT * FROM clinics ORDER BY name ASC"
        );
        res.status(200).json(Result.rows);
    } catch (error) {
        console.error("Error fetching clinic:", error);
        res.status(500).json({ message: "Error fetching clinics" });
    }
};

// add a clinic
async (req, res) => {
    try {
        
    } catch (error) {

    }
};



