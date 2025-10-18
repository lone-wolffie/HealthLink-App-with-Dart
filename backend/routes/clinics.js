import express from "express";
import { getAllClinics, addClinic } from "../controllers/clinics";

const router = express.Router();

// get all clinics route
router.get("/", getAllClinics);
// add a clinic route
router.post("/", addClinic);

export default router;