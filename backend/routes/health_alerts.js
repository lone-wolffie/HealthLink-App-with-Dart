import express from "express";
import { getAllActiveAlerts, addHealthAlert, deactivateHealthAlert, deleteHealthAlert } from "../controllers/health_alerts.js";

const router = express.Router();

// get all active health alerts route
router.get("/", getAllActiveAlerts);
// add a new health alert route
router.post("/", addHealthAlert);
// deactivate a health alert route
router.patch("/:id/deactivate", deactivateHealthAlert);
// delete health alert route
router.delete("/:id", deleteHealthAlert);

export default router;