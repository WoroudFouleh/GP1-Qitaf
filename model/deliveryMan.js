const mongoose = require('mongoose');
const db = require('../config/db');
const deliveryManSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  password: {
    type: String,
    required: true,
  },
  location: {
    city: { type: String, required: true },
    address: { type: String, required: true },
  },
  status: {
    type: String,
    enum: ['Busy', 'Available', 'OutOfService'],
    default: 'Available',
  },
  profileImage: {
    type: String,
    required: false, // Assume URL to the image is required
  },
  phoneNumber: {
    type: String,
    required: true,
  },
  licenseNumber: {
    type: String,
    required: false,
  },
  licenseFile: {
    type: String, // URL to the uploaded file
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = db.model('DeliveryMan', deliveryManSchema);
