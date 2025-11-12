import { db } from "../config/db.js"; 

// create a new appointment
export const createAppointment = async (req, res) => {
  try {
    const { user_id, clinic_id, appointment_at, purpose, notes } = req.body;

    if (!user_id || !clinic_id || !appointment_at) {
      return res.status(400).json({ error: "user id, clinic id and appointment time are required" });
    }

    const result = await db.query(
      `INSERT INTO appointments (user_id, clinic_id, appointment_at, purpose, notes)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [user_id, clinic_id, appointment_at, purpose, notes]
    );

    res.status(200).json({ 
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

    const result = await db.query(
      `SELECT a.*, c.name AS clinic_name, c.address
       FROM appointments a
       JOIN clinics c ON a.clinic_id = c.id
       WHERE a.user_id = $1
       ORDER BY a.appointment_at ASC`,
      [user_id]
    );

    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching appointments:", error);
    res.status(500).json({ error: "Failed to get user appointments" });
  }
};


// cancel an appointment
export const cancelAppointment = async (req, res) => {
  try {
    const { id } = req.params;

    await db.query(
      "UPDATE appointments SET status = 'cancelled' WHERE id = $1",
      [id]
    );

    res.status(200).json({ message: "Appointment cancelled" });
  } catch (error) {
    console.error("Error cancelling appointment:", error);
    res.status(500).json({ error: "Failed to cancel an appointment" });
  }
};

// mark an appointment as complete
export const completeAppointment = async (req, res) => {
  try {
    const { id } = req.params;

    await db.query(
      "UPDATE appointments SET status = 'completed' WHERE id = $1",
      [id]
    );

    res.status(200).json({ message: "Appointment marked as completed" });
  } catch (error) {
    console.error("Error marking appointment as completed:", error);
    res.status(500).json({ error: "Failed to mark appointment as completed" });
  }
};

// reschedule an appointment
export const rescheduleAppointment = async (req, res) => {
  try {
    const { id } = req.params;
    const { appointment_at } = req.body;

    await db.query(
      "UPDATE appointments SET appointment_at = $1, updated_at = NOW() WHERE id = $2",
      [appointment_at, id]
    );

    res.status(200).json({ message: "Appointment rescheduled successfully" });
  } catch (error) {
    console.error("Error rescheduling an appointment:", error);
    res.status(500).json({ error: "Failed to reschedule an appointment" });
  }
};
