import { db } from "../config/db.js";

// get user profile
export const getUserProfile = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      "SELECT id, fullname, email, phonenumber, username, created_at FROM users WHERE id = $1",
      [id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ message: "Failed to fetch user profile" });
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
    res.status(500).json({ message: "Failed to update profile" });
  }
};
