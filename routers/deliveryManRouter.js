const express = require('express');
const router = express.Router();
const deliveryManController = require('../controller/deliveryManController');

// Register a delivery man
router.post('/registerDeliveryMan', deliveryManController.registerDeliveryMan);

// Get all delivery men
router.get('/getAllDekiveryMens', deliveryManController.getDeliveryMen);

// Get a delivery man by ID
router.get('/getDeliveryById/:id', deliveryManController.getDeliveryManById);

// Update a delivery man
router.put('/editDeliveryMan/:id', deliveryManController.updateDeliveryMan);

// Delete a delivery man
router.delete('/deleteDeliveryMan/:id', deliveryManController.deleteDeliveryMan);
router.post('/updateManStatus', deliveryManController.updateDeliveryManStatus);
router.post('/updateManCoordinates', deliveryManController.updateDeliveryManCoordinates);
module.exports = router;
