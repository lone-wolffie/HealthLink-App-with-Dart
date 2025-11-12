import express from "express";
import { createAppointment, getUserAppointments, cancelAppointment, completeAppointment, rescheduleAppointment } from "../controllers/appointments.js";

const router = express.Router();

// Book appointment
router.post("/", createAppointment);
// Get all appointments for a specific user
router.get("/:user_id", getUserAppointments);
// Cancel an appointment
router.patch("/:id/cancel", cancelAppointment);
// complete an appointment
router.put("/:id/complete", completeAppointment);
// reschedule an appointment
router.put("/:id/reschedule", rescheduleAppointment);

export default router;
