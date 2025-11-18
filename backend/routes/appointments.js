import express from "express";
import { createAppointment, getUserAppointments, cancelAppointment, completeAppointment, rescheduleAppointment } from "../controllers/appointments.js";

const router = express.Router();

// book appointment route
router.post("/", createAppointment);
// get all appointments for a specific user route
router.get("/:user_id", getUserAppointments);
// cancel an appointment route
router.patch("/:id/cancel", cancelAppointment);
// complete an appointment route
router.put("/:id/complete", completeAppointment);
// reschedule an appointment route
router.put("/:id/reschedule", rescheduleAppointment);

export default router;
