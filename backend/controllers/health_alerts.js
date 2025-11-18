import { db } from "../config/db.js";

// get all active health alerts
export const getAllActiveAlerts = async (req, res) => {
    try {
      const result = await db.query(
        "SELECT * FROM health_alerts WHERE is_active = true ORDER BY published_date DESC"
      );

      res.status(200).json(result.rows);
    } catch (error) {
      console.error("Error getting all active health alerts:", error);
      res.status(500).json({ error: "Failed to fetch all active health alerts" });
    }
};

// add a new health alert
export const addHealthAlert = async (req, res) => {
    try {
      const { title, message, severity, location, alert_type, icon } = req.body;

      if(!title || !message || !severity) {
        return res.status(400).json({ message: "The title, message and severity are required" });
      }

      await db.query(
        `INSERT INTO health_alerts (title, message, severity, location, alert_type, icon, is_active)
        VALUES ($1, $2, $3, $4, $5, $6, true)`,
        [title, message, severity, location || null, alert_type || null, icon || null]
      );

      res.status(201).json({ message: "Health alert created successfully." });
    } catch (error) {
      console.error("Error creating a new health alert:", error);
      res.status(500).json({ error: "Failed to create a new health alert" });
    }
};

// deactivate an alert from true to false
export const deactivateHealthAlert = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      "UPDATE health_alerts SET is_active = false WHERE id = $1 RETURNING *",
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "Health alert not found." });
    }

    res.status(200).json({ message: "Health alert deactivated successfully." });
  } catch (error) {
    console.error("Error deactivating health alert:", error);
    res.status(500).json({ error: "Failed to deactivate health alert." });
  }
}; 

// delete an alert
export const deleteHealthAlert = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      "DELETE FROM health_alerts WHERE id = $1 RETURNING *", 
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "Health alert not found." });
    }

    res.status(200).json({ message: "Health alert deleted successfully." });
  } catch (error) {
    console.error("Error deleting health alert:", error);
    res.status(500).json({ error: "Failed to delete health alert." });
  }
};
