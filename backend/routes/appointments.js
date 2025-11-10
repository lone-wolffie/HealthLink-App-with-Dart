import express from "express";
import { createAppointment, getUserAppointments, cancelAppointment } from "../controllers/appointments.js";

const router = express.Router();

// Book appointment
router.post("/", createAppointment);
// Get all appointments for a specific user
router.get("/user/:user_id", getUserAppointments);
// Cancel an appointment
router.patch("/:id/cancel", cancelAppointment);

export default router;
