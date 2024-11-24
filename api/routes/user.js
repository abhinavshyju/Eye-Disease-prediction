const express = require("express");
const multer = require("multer");
const path = require("path");
const { Storage, User } = require("../model");
const { url } = require("inspector");
const GenerateAi = require("../ai");



const router = express.Router()

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads');
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    },
});

const upload = multer({ storage: storage });




router.post("/upload",
    upload.single("image"),
    async (req, res, next) => {
        const { title, isChecked, token } = req.body;

        try {
            var response;
            if (isChecked === "false") {

                response = ""
            } else {
                response = await GenerateAi(req.file.path)
            }

            const user = await User.findOne({ where: { session_token: token } });
            await Storage.create({
                user_id: user.id,
                title: title,
                url: req.file.filename,
                data: response
            })
            res.json({ "message": "Doc uploaded successfully." })
        } catch (error) {
            console.log(error)
            res.json({ message: "Error uploading file" })
        }


    })

router.get("/getdoc/:token", async (req, res) => {
    const token = req.params.token;
    const user = await User.findOne({ where: { session_token: token } });
    const data = await Storage.findAll({ where: { user_id: user.id } })
    res.json(data)
})
router.get("/getdocin/:index/:token", async (req, res) => {
    const token = req.params.token;
    const index = req.params.index
    const user = await User.findOne({ where: { session_token: token } });
    const data = await Storage.findAll({ where: { user_id: user.id } })
    res.json(data[index])
})

router.get("/doc/:name", (req, res) => {
    res.sendFile(path.join(__dirname, `../uploads/${req.params["name"]}`));
})

module.exports = router;
