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
        required: true
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
            'رفح'],
        required: true
    },
    location: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: true
    }
});

module.exports = db.model('Product', productSchema);
