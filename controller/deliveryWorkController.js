// controllers/deliveryController.js
const DeliveryRequest = require('../model/deliveryWorkRequest');
const path = require('path');
const fs = require('fs');

exports.createDeliveryRequest = async (req, res) => {
  try {
    const { firstName, lastName, email, phoneNumber, city, idNumber, birthDate } = req.body;

    if (!req.file) {
      return res.status(400).json({ message: 'License file is required.' });
    }

    const licenseFilePath = req.file.path;

    const deliveryRequest = new DeliveryRequest({
      firstName,
      lastName,
      email,
      phoneNumber,
      city,
      idNumber,
      birthDate: JSON.parse(birthDate), // Expecting a JSON string for birthDate
      licenseFile: licenseFilePath,
    });

    await deliveryRequest.save();
    res.status(201).json({ message: 'Delivery request created successfully!' });
  } catch (error) {
    console.error('Error creating delivery request:', error);
    res.status(500).json({ message: 'An error occurred while processing the request.' });
  }
};
