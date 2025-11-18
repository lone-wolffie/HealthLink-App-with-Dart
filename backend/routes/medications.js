import express from "express";
import { createMedication, getUserMedication, getMedication, deleteMedication } from "../controllers/medications.js";

const router = express.Router();

// create a medication route
router.post("/", createMedication);
// get all medications for a specific user route
router.get("/:user_id", getUserMedication);
// get a specific medication route
router.get("/med/:id", getMedication);
// delete a specific medication route
router.delete("/:id", deleteMedication);

export default router;