const mongoose = require('mongoose');
const db = require('../config/db');
const deliveryRequestSchema = new mongoose.Schema({
  firstName: { type: String, required: true }, // First name of the applicant
  lastName: { type: String, required: true }, // Last name of the applicant
  email: { type: String, required: true }, // Applicant's email address
  phoneNumber: { type: String, required: true }, // Applicant's phone number
  idNumber: { type: String, required: true }, // Applicant's ID number
  city: { type: String, required: true }, // Selected city
  birthDate: { 
    day: { type: String, required: true }, 
    month: { type: String, required: true }, 
    year: { type: String, required: true } 
  }, // Birthdate as a structured object
  licenseFile: { type: String, required: true }, // File path and name of the driver's license
  createdAt: { type: Date, default: Date.now } // Timestamp when the request is submitted
});

// Compile the schema into a model
module.exports = db.model('DeliveryRequest', deliveryRequestSchema);


