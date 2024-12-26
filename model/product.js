// productModel.js

const mongoose = require('mongoose');
const db = require('../config/db');
const productSchema = new mongoose.Schema({
    image: {
        type: String,
    },username: {
        type: String,
        required: true
    },name: {
        type: String,
        required: true
    },
    type: {
        type: String,
        enum: [
            'محصول',
            'منتج غذائي',
            'منتج غير غذائي',
        ],
        required: true
    },
    quantity: {
        type: Number,
        required: true,
        
    },
    quantityType: {
        type: String,
        enum: [
            'كيلو',
            'لتر',
            'علبة'], // List of allowed cities
        required: true
    },
    price: {
        type: Number,
        required: true
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
        required: true
    },
    coordinates: {
        type: {
          lat: { type: Number, required: true }, // Latitude
          lng: { type: Number, required: true }  // Longitude
        },
        required: false // Optional, make required if all products must have coordinates
    },
    description: {
        type: String,
        required: true
    },
    rate: {
        type: Number,
        default: 0, // Initial value
        min: 0, // Ensures the rate cannot go below 0
        max: 5 // Optional: Add if you want to restrict ratings to a 0-5 scale
    },
    preparationTime: {
        type: String, // You can use String for flexible time formats like "2 hours" or "30 minutes"
        required: true // Make it required if every product needs this field
    },
    preparationTimeUnit:{
        type: String, // You can use String for flexible time formats like "2 hours" or "30 minutes"
        required: true
    },
    publishingDate: {
        type: Date,
        default: Date.now, // Automatically sets the current date
      },
});

module.exports = db.model('Product', productSchema);