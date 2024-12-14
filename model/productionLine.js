const mongoose = require('mongoose');
const db = require('../config/db');
const productionLineSchema = new mongoose.Schema({
  ownerUsername:{
    type: String,
    required: true,
  },
    image: {

    type: String,
    // Path or URL of the image
  },
  lineName: {
    type: String,
    required: true,
    trim: true, // Removes leading/trailing whitespaces
  },
  materialType: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    required: true,
    trim: true,
  },
  phoneNumber: {
    type: String,
    required: true,
    // Validates phone number with 7-15 digits
  },
  city: {
    type: String,
    enum: [
        'القدس',
'بيت لحم',
'طوباس',
'رام الله',
'نابلس',
'الخليل',
'جنين',
'طولكرم',
'قلقيلية',
'سلفيت',
'أريحا',
'غزة',
'دير البلح',
'خان يونس',
'رفح',
'الداخل الفلسطيني'],
    required: true
},
  location: {
    type: String,
    required: true,
    trim: true,
  },
  coordinates: {
    type: {
      lat: { type: Number, required: true }, // Latitude
      lng: { type: Number, required: true }  // Longitude
    },
    required: false // Optional, make required if all products must have coordinates
  },
  timeOfPreparation: {
    type: String, // Time in minutes/hours
    required: true,
  },
  unitTimeOfPreparation: {
    type: String, // Time in minutes/hours
    required: true,
  },
  price: {
    type: Number,
    required: true,
    min: 0,
  },
  quantityUnit: {
    type: String,
    required: true,
    trim: true,
  },
  startWorkTime: {
    type: String,
    required: true,
     // Validates time in HH:mm format
  },
  endWorkTime: {
    type: String,
    required: true,
    // Validates time in HH:mm format
  },
  datesOfWork: {
    type: [String], // Array of days (e.g., ['Monday', 'Tuesday'])
    required: true,
  },
  rate: {
    type: Number,
    default: 5, // Initial value
    min: 0, // Ensures the rate cannot go below 0
    max: 5 // Optional: Add if you want to restrict ratings to a 0-5 scale
},
  publishingDate: {
    type: Date,
    default: Date.now, // Automatically sets the current date
  },
});

module.exports = db.model('ProductionLine', productionLineSchema);
