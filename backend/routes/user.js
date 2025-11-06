import express from "express";
import { getUserProfile, updateUserProfile, uploadProfileImage } from "../controllers/user.js";
import upload from "../middleware/profile_image_upload.js";

const router = express.Router();

router.get("/:id", getUserProfile);
router.put("/:id", updateUserProfile);
router.post("/upload-profile/:id", upload.single("profileImage"), uploadProfileImage);

export default router;
