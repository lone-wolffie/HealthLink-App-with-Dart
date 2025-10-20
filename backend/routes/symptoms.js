import express from "express";
import { getSymptomHistory, addSymptom, deleteSymptom } from "../controllers/symptoms.js";

const router = express.Router();

// get all symptoms route
router.get("/:user_id", getSymptomHistory);
// add a new symptom route
router.post("/", addSymptom);
// delete a symptom route
router.delete("/:id", deleteSymptom);

export default router;