// productModel.js

const mongoose = require('mongoose');
const db = require('../config/db');
const landSchema = new mongoose.Schema({
    image: {
        type: String,
    },username: {
        type: String,
        required: true
    },landName: {
        type: String,
        required: true
    },
    cropType: {
        type: String,
        required: true
    },

    workerWages: {
        type: Number,
        required: true
    },
    landSpace: {
        type: Number,
        required: true
    },
    numOfWorkers: {
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
    startDate: {
        type: Date,
        required: true
    },
    endDate: {
        type: Date,
        required: true
    },
    startTime: {
        type: String,
        required: true
    },
    endTime: {
        type: String,
        required: true
    }

    
});

module.exports = db.model('Land', landSchema);
