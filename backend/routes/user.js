import express from "express";
import { getUserProfile, updateUserProfile, uploadProfileImage } from "../controllers/user.js";
import upload from "../middleware/profile_image_upload.js";

const router = express.Router();

// get user profile route
router.get("/:id", getUserProfile);
// update existing user profile route
router.put("/:id", updateUserProfile);
// upload user profile image
router.post("/upload-profile/:id", upload.single("profileImage"), uploadProfileImage);

export default router;
