const express = require("express");
const multer = require("multer");
const path = require("path");
const { Storage, User, Diagno, BMI, Log } = require("../model");
const { url } = require("inspector");
const GenerateAi = require("../ai");

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage: storage });

router.post("/upload", upload.single("image"), async (req, res, next) => {
  const { title, isChecked, token } = req.body;

  try {
    var response;
    if (isChecked === "false") {
      response = "";
    } else {
      response = await GenerateAi(req.file.path);
    }

    const user = await User.findOne({ where: { session_token: token } });
    await Log.create({
      email: user.email,
      date: new Date(),
      type: "process",
      log: "Eye testing runned",
    });
    await Storage.create({
      user_id: user.id,
      title: title,
      url: req.file.filename,
      data: response,
    });
    res.json({ message: "Doc uploaded successfully." });
  } catch (error) {
    console.log(error);
    res.json({ message: "Error uploading file" });
  }
});

router.post("/bmi", async (req, res) => {
  try {
    const { data, token } = req.body;

    if (!data || !data.height || !data.weight || !data.result || !token) {
      return res.status(400).json({ message: "Invalid input data" });
    }

    const user = await User.findOne({
      where: { session_token: token },
    });
    await Log.create({
      email: user.email,
      date: new Date(),
      type: "process",
      log: "BMI calculation runned",
    });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    await BMI.create({
      user_id: user.id,
      height: parseFloat(data.height),
      weight: parseFloat(data.weight),
      result: data.result,
      date: new Date(),
    });

    res.json({ message: "BMI result saved successfully" });
  } catch (error) {
    console.error("Error saving BMI:", error.message);
    res.status(500).json({ message: "Internal server error" });
  }
});
router.post("/eye", async (req, res) => {
  const { data, token } = req.body;

  const user = await User.findOne({
    where: { session_token: token },
  });
  await Log.create({
    email: user.email,
    date: new Date(),
    type: "process",
    log: "Eye result saved",
  });
  await Diagno.create({
    user_id: user.id,
    result: data.result,

    date: new Date(),
  });

  res.json({ message: "Result save done" });
});
router.get("/getdoc/:token", async (req, res) => {
  const token = req.params.token;
  const user = await User.findOne({ where: { session_token: token } });
  const data = await Storage.findAll({ where: { user_id: user.id } });
  res.json(data);
});
router.get("/getdocin/:index/:token", async (req, res) => {
  const token = req.params.token;
  const index = req.params.index;
  const user = await User.findOne({ where: { session_token: token } });
  const data = await Storage.findAll({ where: { user_id: user.id } });
  res.json(data[index]);
});

router.get("/doc/:name", (req, res) => {
  res.sendFile(path.join(__dirname, `../uploads/${req.params["name"]}`));
});

router.get("/getresult/:token", async (req, res) => {
  const token = req.params.token;
  const user = await User.findOne({ where: { session_token: token } });

  if (!user) {
    return res.status(404).json({ error: "User not found" });
  }

  const data1 = await BMI.findAll({ where: { user_id: user.id } });
  const data2 = await Diagno.findAll({ where: { user_id: user.id } });

  const result = [
    ...data1.map((bmi) => ({
      type: "bmi",
      date:
        new Date(bmi.date).getDate() +
        "/" +
        new Date(bmi.date).getMonth() +
        "/" +
        new Date(bmi.date).getFullYear(),
      height: bmi.height,
      weight: bmi.weight,
      result: bmi.result,
    })),
    ...data2.map((eye) => ({
      type: "eye",
      date:
        new Date(eye.date).getDate() +
        "/" +
        new Date(eye.date).getMonth() +
        "/" +
        new Date(eye.date).getFullYear(),
      result: eye.result,
    })),
  ];

  result.sort((a, b) => new Date(a.date) - new Date(b.date));

  res.json(result);
});

module.exports = router;
