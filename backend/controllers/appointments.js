import { db } from "../config/db.js"; 

// create a new appointment
export const createAppointment = async (req, res) => {
  try {
    const { user_id, clinic_id, appointment_at, purpose, notes } = req.body;

    if (!user_id || !clinic_id || !appointment_at) {
      return res.status(400).json({ error: "user id, clinic id and appointment time are required" });
    }

    const result = await pool.query(
      `INSERT INTO appointments (user_id, clinic_id, appointment_at, purpose, notes)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [user_id, clinic_id, appointment_at, purpose, notes]
    );

    res.status(201).json({ 
        message: "Appointment booked successfully", 
        appointment: result.rows[0] 
    });

  } catch (error) {
    console.error("Error creating appointment:", error);
    res.status(500).json({ error: "Failed to create an appointment" });
  }
};


// get appointments for a specific user
export const getUserAppointments = async (req, res) => {
  try {
    const { user_id } = req.params;

    const result = await pool.query(
      `SELECT a.*, c.name AS clinic_name, c.address
       FROM appointments a
       JOIN clinics c ON a.clinic_id = c.id
       WHERE a.user_id = $1
       ORDER BY a.appointment_at ASC`,
      [user_id]
    );

    res.json(result.rows);
  } catch (error) {
    console.error("Error fetching appointments:", error);
    res.status(500).json({ error: "Failed to get user appointments" });
  }
};


// cancel an appointment
export const cancelAppointment = async (req, res) => {
  try {
    const { id } = req.params;

    await pool.query(
      "UPDATE appointments SET status = 'cancelled' WHERE id = $1",
      [id]
    );

    res.json({ message: "Appointment cancelled" });
  } catch (error) {
    console.error("Error cancelling appointment:", error);
    res.status(500).json({ error: "Failed to cancel an appointment" });
  }
};
