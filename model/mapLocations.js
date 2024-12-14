// productModel.js

const mongoose = require('mongoose');
const db = require('../config/db');
const mapSchema = new mongoose.Schema({
    locationName: {
        type: String,
        required: true,
    },
    coordinates: {
        type: {
          lat: { type: Number, required: true }, // Latitude
          lng: { type: Number, required: true }  // Longitude
        },
        required: false // Optional, make required if all products must have coordinates
      },

    publishingDate: {
        type: Date,
        default: Date.now, // Automatically sets the current date
      },

    
});

module.exports = db.model('Map', mapSchema);
