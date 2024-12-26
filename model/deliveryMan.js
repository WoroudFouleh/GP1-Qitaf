const mongoose = require('mongoose');
const db = require('../config/db');
const bcrypt = require('bcrypt');
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
  firstName: {
    type: String,
    required: true,
  },
  lastName: {
    type: String,
    required: true,
  },
  location: {
    type:String,
    required: true
  },
  status: {
    type: String,
    enum: ['Busy', 'Available', 'OutOfService'],
    default: 'Available',
  },
  profileImage: {
    type: String,
    default: null // Assume URL to the image is required
  },
  phoneNumber: {
    type: String,
    required: true,
  },
  licenseNumber: {
    type: String,
    default: null,
  },
  licenseFile: {
    type: String, // URL to the uploaded file
    required: true,
  },
  rate: {
    type: Number,
    default: 0, // Initial value
    min: 0, // Ensures the rate cannot go below 0
    max: 5 // Optional: Add if you want to restrict ratings to a 0-5 scale
},
  createdAt: {
    type: Date,
    default: Date.now,
  },
});
deliveryManSchema.methods.comparePassword = async function(userPassword) {
    try {

        return await bcrypt.compare(userPassword,this.password);
    } catch (err) {
        throw err;
    }
}
module.exports = db.model('DeliveryMan', deliveryManSchema);
