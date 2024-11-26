const mongoose = require('mongoose');
const db = require('../config/db');
const bookingSchema = new mongoose.Schema({
  lineId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Line', // Reference to the Lines collection
    required: true,
  },
  lineName:{
    type: String,
    required: true,
  },
  customerUsername: {
    type: String,
    required: true,
  },
  userPhone: {
    type: String,
    required: true,
  },
  userImage:{
    type: String,
    required: true,
  },
  userFirstName:{
    type: String,
    required: true,
  },
  userLastName:{
    type: String,
    required: true,
  },
  ownerUsername: {
    type: String,
    required: true,
  },
  quantity: {
    type: Number,
    required: true,
    min: 0,
  },
  date:{
    type: Date,
    required: true,

  },
  startTime: {
    type: Date,
    required: true,
  },
  endTime: {
    type: Date,
    required: true,
  },
  totalPrice: {
    type: Number,
    required: true,
    min: 0,
  },
  revenuePrice: {
    type: Number,
    required: true,
    min: 0,
  },
  cropType:{
    type: String,
    required: true,
  },

  status: {
    type: String,
    enum: ['pending', 'confirmed', 'canceled'], // Enum for booking statuses
    default: 'pending',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = db.model('Booking', bookingSchema);


