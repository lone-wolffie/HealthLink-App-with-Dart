import express from "express";
import { getUserProfile, updateUserProfile } from "../controllers/user.js";

const router = express.Router();

router.get("/:id", getUserProfile);
router.put("/:id", updateUserProfile);

export default router;
