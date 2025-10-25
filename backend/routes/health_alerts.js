import express from "express";
import { getAllActiveAlerts, addHealthAlert, deleteHealthAlert } from "../controllers/health-alerts.js";

const router = express.Router();

// get all active health alerts route
router.get("/", getAllActiveAlerts);

// add a new health alert route
router.post("/", addHealthAlert);

// deactivate a health alert route
// router.patch("/:id/deactivate", deactivateHealthAlert);

// DELETE permanently
router.delete("/:id", deleteHealthAlert);

export default router;