const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const model = require('./model');
const app = express()
const port = 3000;


app.use(cors());
// app.use(express.);
app.use(bodyParser.json());


model.User.hasMany(model.Storage, { foreignKey: 'user_id' });
model.Storage.belongsTo(model.User, { foreignKey: 'user_id' });


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
const auth = require("./routes/auth")
const user = require("./routes/user")





app.get('/', (req, res) => res.send('Hello World!'))


// Auth routes 
app.use("/auth", auth);
// User route
app.use("/user", user)

app.listen(port, () => console.log(`Example app listening on port ${port}!`))