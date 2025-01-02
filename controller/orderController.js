const Order = require('../model/order'); // Adjust the path as necessary
const haversine = require('haversine-distance');
exports.registerOrder = async (req, res) => {
  try {
    // Extract data from the request body
    const { username, phoneNumber, location,coordinates, totalPrice, items, deliveryType } = req.body;

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
      status: 'غير مستلم', 
      deliveryType// Default status
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
  const calculateDistance = (coord1, coord2) => {
    const toRadians = (degrees) => (degrees * Math.PI) / 180;
    const R = 6371; // Radius of Earth in kilometers
  
    const dLat = toRadians(coord2.lat - coord1.lat);
    const dLng = toRadians(coord2.lng - coord1.lng);
  
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(toRadians(coord1.lat)) *
        Math.cos(toRadians(coord2.lat)) *
        Math.sin(dLng / 2) ** 2;
  
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  };
  
  const permute = (array) => {
    if (array.length <= 1) return [array];
  
    const permutations = [];
    for (let i = 0; i < array.length; i++) {
      const rest = permute(array.slice(0, i).concat(array.slice(i + 1)));
      for (const r of rest) {
        permutations.push([array[i], ...r]);
      }
    }
  
    return permutations;
  };
  
  const tspBruteForce = (locations) => {
    const permutations = permute([...Array(locations.length).keys()]);
    let shortestDistance = Infinity;
    let bestRoute = null;
  
    for (const path of permutations) {
      let distance = 0;
  
      for (let i = 0; i < path.length - 1; i++) {
        distance += calculateDistance(
          locations[path[i]].location,
          locations[path[i + 1]].location
        );
      }
  
      if (distance < shortestDistance) {
        shortestDistance = distance;
        bestRoute = path;
      }
    }
  
    return bestRoute;
  };
  
  exports.getAllOrdersWithPaths = async (req, res) => {
    try {
      // Fetch all orders (you can filter orders by delivery type if needed)
      const orders = await Order.find({ 'deliveryType': 'fast' });
  
      if (!orders.length) {
        return res.status(404).json({ status: false, error: 'No fast delivery orders found' });
      }
  
      // Loop through orders and calculate the fast delivery path for each order
      const ordersWithPaths = [];
  
      for (const order of orders) {
        const { deliveryManLocation } = req.body; // Assuming deliveryManLocation is sent in the request body
  
        if (!deliveryManLocation) {
          return res.status(400).json({ status: false, error: 'Missing delivery man location' });
        }
  
        // Prepare locations for TSP calculation
        const locations = [
          { location: deliveryManLocation, name: 'Start: Delivery Man Location' },
        ];
  
        order.items.forEach((item) => {
          locations.push({
            location: item.productCoordinates,
            name: `Pick: ${item.productName}`,
          });
        });
  
        locations.push({
          location: order.coordinates,
          name: 'Destination: User Location',
        });
  
        // Solve TSP
        const pathIndices = tspBruteForce(locations);
  
        // Map the path indices back to the original locations with names
        const route = pathIndices.map((index) => ({
          name: locations[index].name,
          coordinates: locations[index].location,
        }));
 // console.log(route);
        // Add the order with its calculated route
        ordersWithPaths.push({
          orderId: order._id,
          orderDetails: order,
          deliveryRoute: route,
        });
      }
      console.log(ordersWithPaths);
      // Return all orders with their respective paths
      return res.status(200).json({ status: true, orders: ordersWithPaths });
    } catch (err) {
      return res.status(500).json({ status: false, error: err.message });
    }
  };
  
  
  
  