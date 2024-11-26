// const Order = require('../model/order'); // Adjust the path as necessary

// exports.registerOrder = async (req, res) => {
//   try {
//     // Extract data from the request body
//     const { username, phoneNumber, location, totalPrice, items } = req.body;

//     // Validation: Check if all required fields are provided
//     if (!username || !phoneNumber || !location || !totalPrice || !items || items.length === 0) {
//       return res.status(400).json({
//         success: false,
//         message: 'All fields are required, including items',
//       });
//     }

//     // Create a new order
//     const order = new Order({
//       username,
//       phoneNumber,
//       location,
//       totalPrice,
//       items,
//       orderDate: new Date(), // Add the current date
//       status: 'غير مستلم', // Default status
//     });

//     // Save the order to the database
//     await order.save();

//     res.status(201).json({
//       success: true,
//       message: 'Order registered successfully',
//       order, // Returning the saved order for confirmation
//     });
//   } catch (error) {
//     console.error('Error registering order:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error. Could not register order.',
//     });
//   }
// };