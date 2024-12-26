const mongoose = require('mongoose');
const db = require('../config/db');
const CartSchema = new mongoose.Schema({
  ownerusername:{
    type: String,
    required: true,
  },
  username: {
    type: String,
    required: true,
  },
  productName: {
    type: String,
    required: true,
  },
  image: {
    type: String,
},
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product', // Assumes there's a separate Product model
    required: true,
  },
  price: {
    type: Number,
    required: true,
  },
  quantity: {
    type: Number,
    required: true,
  },
  quantityType: {
    type: String,
    required: true,
  },
  productCity: {
    type: String,
    required: true,
  },
  productCoordinates: {
    type: {
      lat: { type: Number, required: true },
      lng: { type: Number, required: true },
    },
    required: true,
  },
  
  addedAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = db.model('Cart', CartSchema);