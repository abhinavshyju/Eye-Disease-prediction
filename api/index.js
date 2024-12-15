const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const model = require("./model");
const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(express.json());

model.User.hasMany(model.Storage, { foreignKey: "user_id" });
model.Storage.belongsTo(model.User, { foreignKey: "user_id" });
model.BMI.belongsTo(model.User, { foreignKey: "user_id" });
model.Diagno.belongsTo(model.User, { foreignKey: "user_id" });

app.set("view engine", "ejs");
app.set("views", "./views");
(async () => {
  try {
    await model.sequelize.authenticate();
    console.log("Connection has been established successfully.");

    await model.sequelize.sync();
    console.log("Database synced, tables created!");
  } catch (error) {
    console.error("Unable to connect to the database:", error);
  }
})();

// Route import
const auth = require("./routes/auth");
const user = require("./routes/user");
const admin = require("./routes/admin");
const hospital = require("./routes/hospital");
const eye = require("./routes/eye");

app.get("/", (req, res) => res.render("login"));

// Auth routes
app.use("/auth", auth);
// User route
app.use("/user", user);
// Hospital route
app.use("/hospital", hospital);
// Eye route
app.use("/eye", eye);

// Admin routes
app.use("/admin", admin);

app.listen(port, () => console.log(`Example app listening on port ${port}!`));
