const mongoose = require('mongoose');
const db = require('../config/db');

// Define the schema
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
  status: {
    type: String,
    default: "pending"
  },
  licenseFile: { type: String, required: true }, // File path and name of the driver's license
  reqId: { type: Number, unique: true }, // Incrementing request ID
  createdAt: { type: Date, default: Date.now } // Timestamp when the request is submitted
});

// Add pre-save middleware to auto-increment reqId
deliveryRequestSchema.pre('save', async function (next) {
  if (this.isNew) {
    // Get the maximum reqId in the collection
    const lastRequest = await db.model('DeliveryRequest', deliveryRequestSchema)
                                .findOne({})
                                .sort({ reqId: -1 }); // Sort by reqId in descending order

    // Start at 10 if there are no records, otherwise increment
    this.reqId = lastRequest ? lastRequest.reqId + 1 : 10;
  }
  next();
});

// Compile the schema into a model
module.exports = db.model('DeliveryRequest', deliveryRequestSchema);
