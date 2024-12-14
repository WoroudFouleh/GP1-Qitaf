// productModel.js

const mongoose = require('mongoose');
const db = require('../config/db');
const mainAdSchema = new mongoose.Schema({
    image: {
        type: String,
        required: true
    },
    publishingDate: {
        type: Date,
        default: Date.now, // Automatically sets the current date
      },
});

module.exports = db.model('MainAd', mainAdSchema);
