const express = require("express");
const bodyParser = require("body-parser");
const axios = require("axios");
const path = require("path");

const app = express();
const PORT = 3000;

// Flask backend URL — uses Docker Compose service name "backend"
const FLASK_URL = process.env.FLASK_URL || "http://backend:5000";

// Middleware
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, "public")));

// Set EJS as view engine
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

// GET / — Render the form
app.get("/", (req, res) => {
  res.render("index", { error: null });
});

// POST /submit — Send form data to Flask backend
app.post("/submit", async (req, res) => {
  const { name, student_id, email, course, grade } = req.body;

  try {
    const response = await axios.post(`${FLASK_URL}/submit`, {
      name,
      student_id,
      email,
      course,
      grade,
    });

    const result = response.data;
    res.render("result", { result });
  } catch (err) {
    // Handle Flask validation errors (422) or network issues
    if (err.response && err.response.data) {
      const flaskError = err.response.data;
      res.render("result", { result: flaskError });
    } else {
      res.render("result", {
        result: {
          success: false,
          errors: ["Could not connect to the backend. Please try again."],
        },
      });
    }
  }
});

app.listen(PORT, () => {
  console.log(`Frontend server running on http://localhost:${PORT}`);
});
