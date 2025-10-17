import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import dotenv from "dotenv";

// import necessary routes
import signupLoginRoutes from "./routes/signup-login.js";

dotenv.config();


const app = express();
const port = process.env.PORT || 3000;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

// Routes usage
app.use("/api/auth", signupLoginRoutes);

//get route
app.get("/", (req, res) => {
    res.send("HealthLink App running");
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});