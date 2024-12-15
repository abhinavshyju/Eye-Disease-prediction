const express = require("express");
const { User, Password, Log } = require("../model");
const { where } = require("sequelize");
const router = express.Router();
const crypto = require("crypto");

router.get("/", (req, res) => {
  res.send("Auth route");
});

router.post("/signup", async (req, res) => {
  console.log(req.body);
  const reqbody = req.body;
  try {
    const token = crypto.randomBytes(16).toString("hex");

    const data = await User.create({
      name: reqbody.name,
      email: reqbody.email,
      password: reqbody.password,
      session_token: token,
    });
    await Log.create({
      email: data.email,
      date: new Date(),
      type: "auth",
      log: "New user created",
    });
    return res.json({ message: "New user created", user: data });
  } catch (error) {
    console.error("Error in insertion :", error.errors[0].message);
    if (error.errors[0].type === "unique violation") {
      return res.json({ message: "User already exsist" });
    }
  }
});

router.post("/login", async (req, res) => {
  const reqbody = req.body;
  try {
    const user = await User.findOne({ where: { email: reqbody.email } });
    if (!user) {
      return res.json({ message: "User not found" });
    }
    if (user.password != reqbody.password) {
      return res.json({ message: "Invalid password" });
    }
    await Log.create({
      email: user.email,
      date: new Date(),
      type: "auth",
      log: "User logged in",
    });
    try {
      const token = crypto.randomBytes(16).toString("hex");
      await User.update(
        { session_token: token },
        { where: { email: user.email } }
      );
      res.json({
        message: "User logged in",
        user: { ...user.toJSON(), session_token: token },
      });
    } catch (error_1) {
      console.error("Error during session update :", error_1);
      res.json({ message: "Internal server error", error: error_1.message });
    }
  } catch (error) {
    console.error("Error during login:", error);
    res.json({ message: "Internal server error", error: error.message });
  }
});

router.post("/setpass", async (req, res) => {
  const reqbody = req.body;
  try {
    const user = await User.findOne({
      where: { session_token: reqbody.token },
    });
    await Log.create({
      email: user.email,
      date: new Date(),
      type: "auth",
      log: "User password set",
    });

    if (user) {
      try {
        await Password.create({
          user_id: user.id,
          password: reqbody.data.password,
        });
        res.status(200).json({
          password: reqbody.data.password,
        });
      } catch (error) {
        console.log(error);
        res.json({ message: "Internal server error" });
      }
    }
  } catch (error) {
    console.log(error);
    res.json({ message: "Internal server error" });
  }
});
router.get("/getpass/:token", async (req, res) => {
  const token = req.params.token;
  try {
    const user = await User.findOne({ where: { session_token: token } });
    if (user) {
      const password = await Password.findOne({ where: { user_id: user.id } });
      if (password) {
        console.log("password :" + password);
        res.json({ message: password.password });
      } else {
        console.log("Password not found.");
        res.json({ message: "Password not found" });
      }
    } else {
      res.json({ message: "User not found" });
    }
  } catch (error) {
    console.log(error);
    res.json({ message: "Internal server error" });
  }
});

router.post("/updatepass", async (req, res) => {
  const reqbody = req.body;
  const token = reqbody.token;
  try {
    const user = await User.findOne({ where: { session_token: token } });
    if (user) {
      await Password.update(
        { password: reqbody.data.password },
        { where: { user_id: user.id } }
      );
      res.json({ message: "Password updated" });
    } else {
      res.json({ message: "User not found" });
    }
  } catch (error) {
    console.log(error);
    res.json({ message: "Internal server error" });
  }
});

module.exports = router;
