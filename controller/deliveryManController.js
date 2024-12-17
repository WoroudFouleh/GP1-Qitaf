const DeliveryMan = require('../model/deliveryMan');
const bcrypt = require('bcrypt');

// Register a delivery man
exports.registerDeliveryMan = async (req, res) => {
  try {
    const {
      username,
      email,
      password,
      firstName,
      lastName,
      location,
      profileImage,
      phoneNumber,
      licenseNumber,
      licenseFile,
    } = req.body;

    // Check if email or username already exists
    const existingUser = await DeliveryMan.findOne({ $or: [{ email }, { username }] });
    if (existingUser) {
      return res.status(400).json({ message: 'Username or Email already exists.' });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create a new delivery man
    const newDeliveryMan = new DeliveryMan({
      username,
      email,
      password: hashedPassword,
      firstName,
      lastName,
      location,
      profileImage,
      phoneNumber,
      licenseNumber,
      licenseFile,
    });

    // Save to the database
    await newDeliveryMan.save();

    res.status(201).json({
      message: 'Delivery man registered successfully.',
      data: {
        username: newDeliveryMan.username,
        email: newDeliveryMan.email,
        location: newDeliveryMan.location,
        status: newDeliveryMan.status,
      },
    });
  } catch (error) {
    console.error('Error registering delivery man:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
exports.getDeliveryMen = async (req, res) => {
    try {
      const deliveryMen = await DeliveryMan.find();
      res.status(200).json({ status: true,deliveryMen });
    } catch (error) {
      console.error('Error fetching delivery men:', error);
      res.status(500).json({status: false, message: 'Internal Server Error' });
    }
  };
  exports.getDeliveryManById = async (req, res) => {
    try {
      const { id } = req.params;
      const deliveryMan = await DeliveryMan.findById(id);
      if (!deliveryMan) {
        return res.status(404).json({ message: 'Delivery man not found.' });
      }
      res.status(200).json({ data: deliveryMan });
    } catch (error) {
      console.error('Error fetching delivery man:', error);
      res.status(500).json({ message: 'Internal Server Error' });
    }
  };
  
  // Update a delivery man
  exports.updateDeliveryMan = async (req, res) => {
    try {
      const { id } = req.params;
      const updates = req.body;
  
      // If updating password, hash it
      if (updates.password) {
        updates.password = await bcrypt.hash(updates.password, 10);
      }
  
      const updatedDeliveryMan = await DeliveryMan.findByIdAndUpdate(id, updates, { new: true });
  
      if (!updatedDeliveryMan) {
        return res.status(404).json({ message: 'Delivery man not found.' });
      }
  
      res.status(200).json({
        message: 'Delivery man updated successfully.',
        data: updatedDeliveryMan,
      });
    } catch (error) {
      console.error('Error updating delivery man:', error);
      res.status(500).json({ message: 'Internal Server Error' });
    }
  };
  
  // Delete a delivery man
  exports.deleteDeliveryMan = async (req, res) => {
    try {
      const { id } = req.params;
      const deletedDeliveryMan = await DeliveryMan.findByIdAndDelete(id);
  
      if (!deletedDeliveryMan) {
        return res.status(404).json({ message: 'Delivery man not found.' });
      }
  
      res.status(200).json({ message: 'Delivery man deleted successfully.' });
    } catch (error) {
      console.error('Error deleting delivery man:', error);
      res.status(500).json({ message: 'Internal Server Error' });
    }
  };
