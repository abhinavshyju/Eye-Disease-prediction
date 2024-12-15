const express = require("express");
const router = express.Router();
const axios = require("axios");
const fs = require("fs");
const { measureMemory } = require("vm");
const multer = require("multer");
const path = require("path");
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage: storage });
router.post("/", upload.single("image"), async (req, res, next) => {
  const axios = require("axios");
  const fs = require("fs");

  const image = fs.readFileSync(`./uploads/${req.file.filename}`, {
    encoding: "base64",
  });

  axios({
    method: "POST",
    url: "https://detect.roboflow.com/eyesddfs/2",
    params: {
      api_key: "QPrHHjQkHSY1x46ItsPJ",
    },
    data: image,
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
  })
    .then(function (response) {
      const prediction = response.data.predictions;
      if (prediction.length !== 0) {
        let rate = 0;
        const predictions = response.data.predictions.map(
          (prediction) => prediction.confidence
        );
        rate = predictions.reduce((a, b) => a + b, 0) / predictions.length;
        if (rate > 0.5) {
          return res.json({
            message: "Eyes detected",
          });
        } else {
          return res.status(200).json({
            message: "No eyes detected",
          });
        }
      }

      return res.status(200).json({
        message: "No eyes detected",
      });
    })
    .catch(function (error) {
      console.log(error.message);
      return res.status(200).json({
        message: "No eyes detected",
      });
    });
});

module.exports = router;
