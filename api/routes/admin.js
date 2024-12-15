const express = require("express");
const session = require("express-session");
const bcrypt = require("bcrypt");
const { Doctors, Log } = require("../model");
const { where } = require("sequelize");
const router = express.Router();

// Session middleware
router.use(
  session({
    secret: "your-secret-key",
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false }, // Set to true if using HTTPS
  })
);

// Middleware to protect routes
function isAuthenticated(req, res, next) {
  if (req.session.user) {
    next();
  } else {
    res.redirect("/admin/login");
  }
}

// Login Page
router.get("/login", (req, res) => {
  res.render("login");
});

// Handle Login
router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  try {
    if (email !== "admin@admin.com") {
      return res.status(401).send("Invalid credentials");
    }

    const adminUser = { adminUser: 123, password: "password" };
    if (password !== adminUser.password) {
      return res.status(401).send("Invalid credentials");
    }
    req.session.user = { id: adminUser.id, email: adminUser.email };
    res.redirect("/admin/dashboard");
  } catch (error) {
    console.error("Error during login:", error);
    res.status(500).send("Internal Server Error");
  }
});

router.get("/logout", isAuthenticated, async (req, res) => {
  try {
    req.session.destroy((err) => {
      if (err) {
        return res.status(500).send("Logout failed");
      }
      res.redirect("/admin/login");
    });
  } catch (error) {
    console.error("Error during logout:", error);
    res.status(500).send("Internal Server Error");
  }
});

// Dashboard - Protected Route
router.get("/dashboard", isAuthenticated, async (req, res) => {
  try {
    const doctorData = await Doctors.findAll();
    res.render("dashboard", { doctors: doctorData });
  } catch (error) {
    console.error("Error fetching doctor data:", error);
    res.status(500).send("Internal Server Error");
  }
});

// Add Doctor - Protected Route
router.get("/add-doctor", isAuthenticated, async (req, res) => {
  res.render("add-doctor");
});

router.post("/add-doctor", isAuthenticated, async (req, res) => {
  try {
    await Doctors.create(req.body);
    res.json({ message: "Doctor added" });
  } catch (error) {
    console.error("Error adding doctor:", error);
    res.status(500).send("Internal Server Error");
  }
});

// Edit Doctor - Protected Route
router.get("/edit-doctor/:id", isAuthenticated, async (req, res) => {
  try {
    const doctor = await Doctors.findByPk(req.params.id);
    if (!doctor) {
      return res.status(404).send("Doctor not found");
    }
    res.render("edit-doctor", { doctor });
  } catch (error) {
    console.error("Error fetching doctor:", error);
    res.status(500).send("Internal Server Error");
  }
});

router.post("/edit-doctor/:id", isAuthenticated, async (req, res) => {
  try {
    console.log(req.body);
    const doctor = await Doctors.findByPk(req.params.id);
    if (!doctor) {
      return res.status(404).send("Doctor not found");
    }

    const response = await Doctors.update(req.body, {
      where: {
        id: req.params.id,
      },
    });
    res.redirect("/admin/dashboard");
  } catch (error) {
    console.error("Error updating doctor:", error);
    res.status(500).send("Internal Server Error");
  }
});

// Delete Doctor - Protected Route
router.post("/delete-doctor/:id", isAuthenticated, async (req, res) => {
  try {
    const doctor = await Doctors.findByPk(req.params.id);
    if (!doctor) {
      return res.status(404).send("Doctor not found");
    }
    await doctor.destroy();
    res.redirect("/admin/dashboard");
  } catch (error) {
    console.error("Error deleting doctor:", error);
    res.status(500).send("Internal Server Error");
  }
});

// Logout
router.post("/logout", (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.status(500).send("Logout failed");
    }
    res.redirect("/admin/login");
  });
});

router.get("/activity", isAuthenticated, async (req, res) => {
  try {
    const logData = await Log.findAll();
    res.render("activity", { logs: logData });
  } catch (error) {
    console.error("Error fetching log data:", error);
    res.status(500).send("Internal Server Error");
  }
});

module.exports = router;
