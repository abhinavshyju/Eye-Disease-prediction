const { Sequelize, Model, DataTypes } = require("sequelize");


const sequelize = new Sequelize({
    dialect: "sqlite",
    storage: "./db.sqlite"
});
class User extends Model { }
User.init({
    name: DataTypes.STRING,
    email: {
        type: DataTypes.STRING,
        unique: true,
        allowNull: false,
    },
    password: DataTypes.STRING,
    session_token: DataTypes.STRING
}, {
    sequelize, modelName: "user"
});

class Storage extends Model { }
Storage.init({
    user_id: {
        type: DataTypes.STRING,
        references: {
            model: User,
            key: 'id'
        }
    },
    title: DataTypes.STRING,
    url: DataTypes.STRING,
    data: {
        type: DataTypes.STRING,
        allowNull: true

    }
}, {
    sequelize, modelName: "storage"
});

class Password extends Model { }
Password.init({
    user_id: {
        type: DataTypes.STRING,
        references: {
            model: User,
            key: 'id'
        }
    },
    password: DataTypes.INTEGER
}, { sequelize, modelName: "Password" })


module.exports = { sequelize, User, Storage, Password };