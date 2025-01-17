const mongoose = require('mongoose');
const db = require('../config/db');
const orderSchema = new mongoose.Schema({
  username: { type: String, required: true }, // Username as a string
  phoneNumber: { type: String, required: true },
  recepientCity:{ type: String, required: true },
  location: { type: String, required: true },
  coordinates: {
    type: {
      lat: { type: Number, required: true }, // Latitude
      lng: { type: Number, required: true }  // Longitude
    },
    required: false // Optional, make required if all products must have coordinates
  },
  orderDate: { type: Date, default: Date.now },
  totalPrice: { type: Number, required: true },
  status: { type: String, enum: ['مستلم', 'غير مستلم'], default: 'غير مستلم' },
 deliveryType:{
type: String, enum: ['fast', 'slow'], default: 'slow'
 },
  items: [
    {
      ownerusername: {
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
          itemStatus:{
            type: String,
            default: "undelivered"
          },
          itemPreparation:{
            type: String,
            //required: true,
            default: "notReady"
          },
          deliveryUsername:{
            type: String,
            required: false
            
          },
          addedAt: {
            type: Date,
            default: Date.now,
          },
    },
  ],
});

const Order = db.model('Order', orderSchema);
module.exports = Order;