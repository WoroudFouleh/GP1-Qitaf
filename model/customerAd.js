// productModel.js

const mongoose = require('mongoose');
const db = require('../config/db');
const customerAdSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true
    },
    text: {
        type: String,
        required: true
    },
    buttonText: {
        type: String,
        required: true
    },
    image: {
        type: String,
        required: true
    },
    publishingDate: {
        type: Date,
        default: Date.now, // Automatically sets the current date
      },
});

module.exports = db.model('customerAd', customerAdSchema);
