const mongoose = require('mongoose');
const db = require('../config/db');
const workRequestSchema = new mongoose.Schema({
  ownerUsername: {
    type: String,
    required: true,
  },
  workerUsername: {
    type: String,
    required: true,
  },
  workerFirstname: {
    type: String,
    required: true,
  },
  workerLastname: {
    type: String,
    required: true,
  },
  workerProfileImage: {
    type: String,
    
  },
  workerCity: {
    type: String,
    required: true,
  },
  workerGender: {
    type: String,
     // Adjust enum values if needed
    required: true,
  },
  landId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Land', // Assuming you have a Land model
    required: true,
  },
  landName: {
    type: String,
    required: true,
  },
  landLocation: {
    type: String,
    required: true,
  },
  numOfWorkers: {
    type: Number,
    required: true,
    
  },
  workerWage: {
    type: Number,
    required: true,
    
  },
  requestStatus: {
    type: String,
    enum: ['pending', 'accepted', 'rejected', 'cancelled', 'completed'], // Workflow status
    default: 'pending',
  },
  requestDate: {
    type: Date,
    default: Date.now,
  },
  ownerDecisionDate: {
    type: Date,
  },
});

module.exports = db.model('WorkRequest', workRequestSchema);
