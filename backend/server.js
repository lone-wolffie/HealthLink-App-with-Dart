import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import dotenv from "dotenv";

// import necessary routes
import signupLoginRoutes from "./routes/signup-login.js";
import clinicRoutes from "./routes/clinics.js";
import healthTipsRoutes from "./routes/health-tips.js";
import symptomsRoutes from "./routes/symptoms.js";
import healthAlertsRoutes from "./routes/health-alerts.js";

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

// Routes usage
app.use("/api/auth", signupLoginRoutes);
app.use("/api/clinics", clinicRoutes);
app.use("/api/tips", healthTipsRoutes);
app.use("/api/symptoms", symptomsRoutes);
app.use("/api/alerts", healthAlertsRoutes);

//get route
app.get("/", (req, res) => {
    res.send("HealthLink App backend running successfully.");
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});