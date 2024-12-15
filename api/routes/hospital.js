const express = require("express");
const { Doctors } = require("../model");
const router = express.Router();
const { Op } = require("sequelize");

const extractHospitalDetails = (data) => {
  console.log(data.elements);
  if (!data || !data.elements) {
    console.error("Invalid data format");
    return [];
  }
  if (data.elements.length == 0) {
    return [];
  }
  return data.elements.map((element) => {
    const tags = element.tags || {};
    return {
      name: tags.name || "Unknown",
      address: tags["addr:full"] || "Address not available",
      district: tags["addr:district"] || "District not available",
      state: tags["addr:state"] || "State not available",
      postcode: tags["addr:postcode"] || "Postcode not available",
      phone: tags["phone"] || "Phone not available",
      location: {
        lat: element.lat || element.center?.lat,
        lon: element.lon || element.center?.lon,
      },
    };
  });
};
const getNearbyHospitals = async (latitude, longitude, radius = 5000) => {
  const url = "https://overpass-api.de/api/interpreter";

  const query = `
        [out:json][timeout:25];
        (
          node["amenity"="hospital"](around:${radius}, ${latitude}, ${longitude});
          way["amenity"="hospital"](around:${radius}, ${latitude}, ${longitude});
          relation["amenity"="hospital"](around:${radius}, ${latitude}, ${longitude});
          node["amenity"="eye hospital"](around:${radius}, ${latitude}, ${longitude});
          way["amenity"="eye hospital"](around:${radius}, ${latitude}, ${longitude});
          relation["amenity"="eye hospital"](around:${radius}, ${latitude}, ${longitude});
        );
        out center;
    `;

  try {
    const response = await fetch(`${url}?data=${encodeURIComponent(query)}`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();

    return extractHospitalDetails(data);
  } catch (error) {
    console.error("Error fetching nearby hospitals:", error);
    return null;
  }
};

router.get("/nearby-hospitals", async (req, res) => {
  console.log(req.query);
  const hospitals = await getNearbyHospitals(req.query.lat, req.query.lon);
  console.log(hospitals);
  res.json(hospitals);
});

router.get("/doctors", async (req, res) => {
  try {
    const { name, degree, specialization } = req.query;
    const whereClause = {};

    if (name) {
      whereClause.name = Doctors.sequelize.where(
        Doctors.sequelize.fn("LOWER", Doctors.sequelize.col("name")),
        "LIKE",
        `%${name.toLowerCase()}%`
      );
    }

    if (degree) {
      whereClause.degree = Doctors.sequelize.where(
        Doctors.sequelize.fn("LOWER", Doctors.sequelize.col("degree")),
        "LIKE",
        `%${degree.toLowerCase()}%`
      );
    }
    if (specialization) {
      whereClause.specialization = Doctors.sequelize.where(
        Doctors.sequelize.fn("LOWER", Doctors.sequelize.col("specialization")),
        "LIKE",
        `%${specialization.toLowerCase()}%`
      );
    }

    const doctors = await Doctors.findAll({
      where: whereClause,
      limit: 50,
    });
    console.log(doctors);
    res.status(200).json({ success: true, data: doctors });
  } catch (error) {
    console.error("Error fetching doctors:", error);
    res.status(500).json({
      success: false,
      error: "Failed to fetch doctors",
    });
  }
});

module.exports = router;
