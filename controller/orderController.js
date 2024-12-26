const Order = require('../model/order'); // Adjust the path as necessary
const haversine = require('haversine-distance');
exports.registerOrder = async (req, res) => {
  try {
    // Extract data from the request body
    const { username, phoneNumber, location,coordinates, totalPrice, items } = req.body;

    // Validation: Check if all required fields are provided
    if (!username || !phoneNumber || !location || !totalPrice || !items || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required, including items',
      });
    }

    // Create a new order
    const order = new Order({
      username,
      phoneNumber,
      location,
      coordinates,
      totalPrice,
      items,
      orderDate: new Date(), // Add the current date
      status: 'غير مستلم', // Default status
    });

    // Save the order to the database
    await order.save();

    res.status(201).json({
      success: true,
      message: 'Order registered successfully',
      order, // Returning the saved order for confirmation
    });
  } catch (error) {
    console.error('Error registering order:', error);
    res.status(500).json({
      success: false,
      message: 'Server error. Could not register order.',
    });
  }
};
exports.getUserOrders = async (req, res) => {
    const { username } = req.params; // Extract username from request parameters
  
    try {
      // Fetch orders for the given username
      const userOrders = await Order.find({ username }).populate('items.productId');
  
      // Check if orders exist
      if (!userOrders || userOrders.length === 0) {
        return res.status(404).json({ message: 'No orders found for this user.' });
      }
  
      // Send the orders as a response
      res.status(200).json({ status: true, orders: userOrders });
    } catch (error) {
      console.error('Error fetching user orders:', error);
      res.status(500).json({ status: false, message: 'Server error. Please try again later.' });
    }
  };
  function calculateTravelTime(distance, speed = 50) {
    return distance / speed; // Time in hours
  };
  async function tspAlgorithm(locations, startLocation) {
    const result = [];
    let unvisited = [...locations];
    let current = startLocation;
  
    while (unvisited.length > 0) {
      const nearest = unvisited.reduce((closest, loc) => {
        const distance = haversine(current, loc);
        return distance < closest.distance ? { location: loc, distance } : closest;
      }, { distance: Infinity });
  
      result.push(nearest.location);
      current = nearest.location;
      unvisited = unvisited.filter(loc => loc !== nearest.location);
    }
    return result;
  };
 
  exports.groupItems = async (req, res) => {
    try {
      const { deliveryCityCoordinates } = req.body;
      const orders = await Order.find({ "items.itemStatus": "undelivered" });
  
      const allItems = orders.flatMap(order => order.items.filter(item => item.itemStatus === "undelivered"));
  
      const locations = allItems.map(item => item.productCoordinates);
      const groupedLocations = await tspAlgorithm(locations, deliveryCityCoordinates);
  
      const result = groupedLocations.map(location => {
        return {
          location,
          items: allItems.filter(item =>
            item.productCoordinates.lat === location.lat && item.productCoordinates.lng === location.lng),
        };
      });
  
      const groupedWithTime = result.map(group => {
        const distance = haversine(deliveryCityCoordinates, group.location) / 1000; // Convert to km
        const time = calculateTravelTime(distance);
        return { ...group, distance, time };
      });
  
      res.status(200).json({ success: true, groups: groupedWithTime });
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, message: "Server error" });
    }
  };
  