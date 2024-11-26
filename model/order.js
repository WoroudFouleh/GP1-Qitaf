const mongoose = require('mongoose');
const db = require('../config/db');
const orderSchema = new mongoose.Schema({
  username: { type: String, required: true }, // Username as a string
  phoneNumber: { type: String, required: true },
  location: { type: String, required: true },
  orderDate: { type: Date, default: Date.now },
  totalPrice: { type: Number, required: true },
  status: { type: String, enum: ['مستلم', 'غير مستلم'], default: 'غير مستلم' },
  items: [
    {
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
          addedAt: {
            type: Date,
            default: Date.now,
          },
    },
  ],
});

const Order = db.model('Order', orderSchema);
module.exports = Order;
