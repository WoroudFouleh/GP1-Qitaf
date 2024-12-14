// productModel.js

const mongoose = require('mongoose');
const db = require('../config/db');
const productAdSchema = new mongoose.Schema({
    image: {
        type: String,
        required: true
    },
    publishingDate: {
        type: Date,
        default: Date.now, // Automatically sets the current date
      },
});

module.exports = db.model('ProductAd', productAdSchema);
