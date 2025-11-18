import { db } from "../config/db.js";

// get user profile
export const getUserProfile = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT id, fullname, email, phonenumber, username, created_at, profile_image 
      FROM users WHERE id = $1`,
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    const user = result.rows[0];
    if (user.profile_image) {
      user.profile_image = `/uploads/profile/${user.profile_image}`;
    }

    res.status(200).json(user);

  } catch (error) {
    res.status(500).json({ error: "Failed to fetch user profile" });
  }
};

// Update user profile
export const updateUserProfile = async (req, res) => {
  try {
    const { id } = req.params;
    
    const { fullname, email, phonenumber, username } = req.body;

    await db.query(
      `UPDATE users 
      SET fullname = $1, email = $2, phonenumber = $3, username = $4 
      WHERE id = $5`,
      [fullname, email, phonenumber, username, id]
    );

    res.status(200).json({ message: "Profile updated successfully" });
  } catch (error) {
    res.status(500).json({ error: "Failed to update profile" });
  }
};

// upload user profile image
export const uploadProfileImage = async (req, res) => {
  try {
    const { id } = req.params;
    const filename = req.file.filename; 

    if (!req.file) {
      return res.status(400).json({ message: "No image uploaded" });
    }
    
    await db.query(
      "UPDATE users SET profile_image = $1 WHERE id = $2",
      [filename, id]
    );

    return res.status(200).json({
      message: "Profile image uploaded successfully",
      imageURL: `/uploads/profile/${filename}`,
    });
    
  } catch (error) {
    console.error("Error uploading profile image:", error);
    res.status(500).json({ error: "Failed to upload profile image" });
  }
};
