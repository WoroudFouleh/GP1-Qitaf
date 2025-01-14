const Order = require('../model/order'); // Adjust the path as necessary
const haversine = require('haversine-distance');
exports.registerOrder = async (req, res) => {
  try {
    // Extract data from the request body
    const { username, phoneNumber,recepientCity, location,coordinates, totalPrice, items, deliveryType } = req.body;

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
      recepientCity,
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
  ////////////fast delivery
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
    const permutations = permute([...Array(locations.length - 1).keys()].map(i => i + 1)); // Exclude the first location (fixed start)
    let shortestDistance = Infinity;
    let bestRoute = null;
  
    for (const path of permutations) {
      const fullPath = [0, ...path]; // Add the starting location at the beginning
      let distance = 0;
  
      for (let i = 0; i < fullPath.length - 1; i++) {
        distance += calculateDistance(
          locations[fullPath[i]].location,
          locations[fullPath[i + 1]].location
        );
      }
  
      // Add the return trip to the starting location (optional for a round trip)
      distance += calculateDistance(
        locations[fullPath[fullPath.length - 1]].location,
        locations[0].location
      );
  
      if (distance < shortestDistance) {
        shortestDistance = distance;
        bestRoute = fullPath;
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
          { location: deliveryManLocation, name: 'الانطلاق: مكانك الحالي' },
        ];
  
        order.items.forEach((item) => {
          locations.push({
            location: item.productCoordinates,
            name: `أحضر: ${item.productName}`,
          });
        });
  
        locations.push({
          location: order.coordinates,
          name: 'نقطة الاستلام للزبون',
        });
  
        // Solve TSP
        const pathIndices = tspBruteForce(locations);
  
        // Map the path indices back to the original locations with names
        const route = pathIndices.map((index) => ({
          name: locations[index].name,
          coordinates: locations[index].location,
        }));
  console.log(order);
        // Add the order with its calculated route
        ordersWithPaths.push({
          orderId: order._id,
          orderDetails: order.toObject(),
          deliveryRoute: route.map(routeItem => ({
            name: routeItem.name,
            coordinates: routeItem.coordinates
        }))
        });
      }
      //console.log(ordersWithPaths);
      //console.log(JSON.stringify(ordersWithPaths, null, 2));
      // Return all orders with their respective paths
      return res.status(200).json({ status: true, orders: ordersWithPaths });
    } catch (err) {
      return res.status(500).json({ status: false, error: err.message });
    }
  };
  
  ////////////////Normal delivery
// Import necessary modules and models


exports.getNormalDeliveryGroups = async (req, res) => {
  try {
    console.log("here del");
    const { deliveryManCity } = req.body;

    if (!deliveryManCity) {
      console.log("here del2");
      return res.status(400).json({ status: false, error: 'Missing delivery man city' });
    }

    // Fetch all undelivered items in normal delivery orders
    const normalOrders = await Order.find({
      'deliveryType': 'slow',
      'items.itemStatus': 'undelivered', // Assuming items have an isDelivered field
    });

    if (!normalOrders.length) {
      console.log("here del3");
      return res.status(404).json({ status: false, error: 'No undelivered items found for normal delivery' });
    }

    // Filter items where the owner’s city matches the delivery man’s city
    const itemsInDeliveryManCity = [];

    normalOrders.forEach((order) => {
      order.items.forEach((item) => {
        if (item.itemStatus == 'undelivered' && item.productCity === deliveryManCity) {
          itemsInDeliveryManCity.push({
            orderId: order._id,
            itemId: item._id,
            productName: item.productName,
            sourceCity: deliveryManCity,
            destinationCity: order.recepientCity, // Assuming coordinates have a city field
            productCoordinates: item.productCoordinates,
          });
        }
      });
    });

    if (!itemsInDeliveryManCity.length) {
      console.log("here del4");
      return res.status(404).json({
        status: false,
        error: 'No items found for delivery in the delivery man’s city',
      });
    }

    // Group items by their destination city
    const groupedItems = {};

    itemsInDeliveryManCity.forEach((item) => {
      const destinationCity = item.destinationCity;
      if (!groupedItems[destinationCity]) {
        groupedItems[destinationCity] = [];
      }
      groupedItems[destinationCity].push(item);
    });

    // Convert grouped items into an array of groups for easier handling
    const groupedItemsArray = Object.entries(groupedItems).map(([city, items]) => ({
      destinationCity: city,
      items,
    }));

    // Return the grouped items to the frontend
    console.log(groupedItemsArray);
    return res.status(200).json({
      status: true,
      groups: groupedItemsArray,
    });
  } catch (err) {
    return res.status(500).json({ status: false, error: err.message });
  }
};


  
