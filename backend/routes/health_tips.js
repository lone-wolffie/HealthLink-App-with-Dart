import express from "express";
import { getAllHealthTips, addHealthTip, deleteHealthTip } from "../controllers/health_tips.js";

const router = express.Router();

// get all health tips route
router.get("/", getAllHealthTips);
// add a new health tip route
router.post("/", addHealthTip);
// delete a health tip route
router.delete("/:id", deleteHealthTip);

export default router;