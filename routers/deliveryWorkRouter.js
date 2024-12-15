// routes/deliveryRoutes.js
const express = require('express');
const multer = require('multer');
const path = require('path');
const deliveryController = require('../controller/deliveryWorkController');

const router = express.Router();

// Multer setup for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Save files to the 'uploads' directory
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); // Unique filename
  },
});

const upload = multer({ storage });

router.post('/sendWorkRequest', upload.single('licenseFile'), deliveryController.createDeliveryRequest);
router.get('/getPendingRequests', deliveryController.getAllRequests);
router.put('/deliveryRequestDecision', deliveryController.updateRequestStatus);
router.post('/generateCredentials', deliveryController.generateCredentials);
module.exports = router;
