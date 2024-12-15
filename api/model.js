const { Sequelize, Model, DataTypes } = require("sequelize");

const sequelize = new Sequelize({
  dialect: "sqlite",
  storage: "./db.sqlite",
});
class User extends Model {}
User.init(
  {
    name: DataTypes.STRING,
    email: {
      type: DataTypes.STRING,
      unique: true,
      allowNull: false,
    },
    password: DataTypes.STRING,
    session_token: DataTypes.STRING,
  },
  {
    sequelize,
    modelName: "user",
  }
);

class Storage extends Model {}
Storage.init(
  {
    user_id: {
      type: DataTypes.STRING,
      references: {
        model: User,
        key: "id",
      },
    },
    title: DataTypes.STRING,
    url: DataTypes.STRING,
    data: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  },
  {
    sequelize,
    modelName: "storage",
  }
);

class Password extends Model {}
Password.init(
  {
    user_id: {
      type: DataTypes.STRING,
      references: {
        model: User,
        key: "id",
      },
    },
    password: DataTypes.INTEGER,
  },
  { sequelize, modelName: "Password" }
);
class Doctors extends Model {}
Doctors.init(
  {
    name: DataTypes.STRING,
    phone: DataTypes.STRING,
    email: DataTypes.STRING,
    degree: DataTypes.STRING,
    specialization: DataTypes.STRING,
    working_address: DataTypes.STRING,
    working_hospital: DataTypes.STRING,
  },
  { sequelize, modelName: "Doctors" }
);
class BMI extends Model {}
BMI.init(
  {
    user_id: {
      type: DataTypes.INTEGER,
      references: {
        model: User,
        key: "id",
      },
      allowNull: false,
    },
    date: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    height: {
      type: DataTypes.FLOAT,
      allowNull: false,
      validate: {
        min: 0,
      },
    },
    weight: {
      type: DataTypes.FLOAT,
      allowNull: false,
      validate: {
        min: 0,
      },
    },
    result: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  { sequelize, modelName: "BMI", timestamps: true }
);

class Diagno extends Model {}
Diagno.init(
  {
    user_id: {
      type: DataTypes.INTEGER,
      references: {
        model: User,
        key: "id",
      },
      allowNull: false,
    },
    date: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    result: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
  },
  { sequelize, modelName: "Diagno", timestamps: true }
);
class Log extends Model {}
Log.init(
  {
    email: {
      type: DataTypes.STRING,
    },
    date: DataTypes.DATE,
    log: DataTypes.STRING,
    type: DataTypes.STRING,
  },
  { sequelize, modelName: "log" }
);

module.exports = {
  sequelize,
  User,
  Storage,
  Password,
  Doctors,
  BMI,
  Diagno,
  Log,
};
