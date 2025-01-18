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
  
  const tspWithConstraints = (locations) => {
    // Separate the delivery point (last location) from the pickup points
    const pickupPoints = locations.slice(1, -1); // Exclude the first (current location) and last (delivery point)
    const deliveryPoint = locations[locations.length - 1]; // Final delivery point
  
    // Generate permutations for pickup points only
    const pickupPermutations = permute([...Array(pickupPoints.length).keys()].map(i => i + 1));
  
    let shortestDistance = Infinity;
    let bestRoute = null;
  
    for (const path of pickupPermutations) {
      const fullPath = [0, ...path]; // Add the starting location at the beginning
      let distance = 0;
  
      // Calculate the distance for the pickup points
      for (let i = 0; i < fullPath.length - 1; i++) {
        distance += calculateDistance(
          locations[fullPath[i]].location,
          locations[fullPath[i + 1]].location
        );
      }
  
      // Add the distance from the last pickup point to the delivery point
      distance += calculateDistance(
        locations[fullPath[fullPath.length - 1]].location,
        deliveryPoint.location
      );
  
      if (distance < shortestDistance) {
        shortestDistance = distance;
        bestRoute = [...fullPath, locations.length - 1]; // Append the delivery point
      }
    }
  
    return bestRoute;
  };
  
  exports.getAllOrdersWithPaths = async (req, res) => {
    try {
      // Fetch all orders (you can filter orders by delivery type if needed)
      const orders = await Order.find({ deliveryType: 'fast', isTakenToDeliver: false });
  
      if (!orders.length) {
        return res.status(404).json({ status: false, error: 'No fast delivery orders found' });
      }
  
      // Loop through orders and calculate the fast delivery path for each order
      const ordersWithPaths = [];
  
      for (const order of orders) {

      //   const allItemsReady = order.items.every((item) => item.itemPreparation === 'ready');

      // if (!allItemsReady) {
      //   console.log("not all ready");
      //   return res.status(400).json({
      //     status: false,
      //     error: `Not all items in order ${order._id} are ready for delivery.`,
      //   });
      // }
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
  
        // Solve TSP with constraints
        const pathIndices = tspWithConstraints(locations);
  
        // Map the path indices back to the original locations with names
        const route = pathIndices.map((index) => ({
          name: locations[index].name,
          coordinates: locations[index].location,
        }));
  
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
        if (item.itemStatus == 'undelivered' && item.itemPreparation == 'ready' && item.itemTaken != 'taken' && item.productCity === deliveryManCity) {
          itemsInDeliveryManCity.push({
            orderId: order._id,
            itemId: item._id,
            productName: item.productName,
            sourceCity: deliveryManCity,
            destinationCity: order.recepientCity, // Assuming coordinates have a city field
            productCoordinates: item.productCoordinates,
          recepientCoordinates: order.coordinates,
          productImage: item.image
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

//////////////

exports.getItemsByOwnerAndPreparation = async (req, res) => {
  try {
    const { ownerusername } = req.params; // Extract ownerusername from the request parameters
console.log(ownerusername);
    if (!ownerusername) {
      console.log("no user");
      return res.status(400).json({ message: 'Owner username is required.' });
    }

    // Query the database for matching items
    const orders = await Order.find({
      'items.ownerusername': ownerusername,
      //'items.itemPreparation': 'notReady',
    }, {
      'items.$': 1 // Project only matching items
    });

    // Extract and consolidate items from all matching orders
    const items = orders.flatMap(order => order.items);

    if (items.length === 0) {
      console.log("no items");
      return res.status(404).json({status: false, message: 'No matching items found.' });
    }

    return res.status(200).json({status: true, items });
  } catch (error) {
    console.error('Error fetching items:', error);
    return res.status(500).json({ message: 'Internal server error.', error });
  }
};

// Update item preparation status in an order
exports.updateItemPreparation = async (req, res) => {
  try {
    console.log("here");
    const { itemId } = req.params;
    const { preparationStatus } = req.body;

    // Find the order and update the item in a single operation using $set
    const order = await Order.findOneAndUpdate(
      { 'items._id': itemId }, // Find the order containing the item
      { $set: { 'items.$.itemPreparation': 'ready' } }, // Update the item's preparation status
      { new: true } // Return the updated order
    );

    if (!order) {
      return res.status(404).json({ message: 'Item not found in any order' });
    }

    // Find the updated item after the update
    const updatedItem = order.items.id(itemId);
    
    if (!updatedItem) {
      return res.status(404).json({ message: 'Item not found' });
    }

    console.log("Updated Order:", order); // Check the saved order
    console.log("donee");

    res.status(200).json({
      message: 'Item preparation status updated successfully',
      updatedItem: updatedItem,
    });
  } catch (error) {
    console.error('Error updating item preparation status:', error);
    res.status(500).json({ message: 'Internal server error', error });
  }
};
////////////
exports.updateItemStatus = async (req, res) => {
  try {
    const { itemIds, deliverymanUsername } = req.body;
console.log(deliverymanUsername);
console.log(itemIds);
    // Validate input
    if (!itemIds || !Array.isArray(itemIds) || itemIds.length === 0) {
      return res.status(400).json({ message: 'Item IDs are required and should be an array.' });
    }
    if (!deliverymanUsername) {
      return res.status(400).json({ message: 'Deliveryman username is required.' });
    }

    // Find and update items in "slow" orders
    const result = await Order.updateMany(
      { 
        deliveryType: 'slow',
        'items._id': { $in: itemIds } // Match any items in the list
      },
      { 
        $set: { 
          'items.$[elem].itemTaken': 'taken', 
          'items.$[elem].deliveryUsername': deliverymanUsername 
        } 
      },
      {
        arrayFilters: [{ 'elem._id': { $in: itemIds } }],
        multi: true // Ensure multiple items in the array are updated
      }
    );

    if (result.modifiedCount === 0) {
      return res.status(404).json({ message: 'No matching items found to update.' });
    }

    res.status(200).json({ 
      message: 'Item status updated successfully.', 
      modifiedCount: result.modifiedCount 
    });
  } catch (error) {
    console.error('Error updating item status:', error);
    res.status(500).json({ message: 'Internal server error.', error });
  }
};

exports.updateFastStatus = async (req, res) => {
  try {
    const { orderId, deliveryUsername } = req.body;
    
    // Find the order by orderId
    const order = await Order.findById(orderId);
    
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }
    console.log(deliveryUsername);
    // Update the order details
    order.fastDeliveryUsername = deliveryUsername;
    order.isTakenToDeliver = true;

    // Save the updated order
    await order.save();
console.log(order.fastDeliveryUsername);
    // Respond with success
    res.status(200).json({ message: 'Order updated successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }

};
exports.getAcceptedOrders = async (req, res) => {
  try {
    const { deliveryUsername } = req.params;

    // Fetch fast orders
    const fastOrders = await Order.find({
      deliveryType: 'fast',
      isTakenToDeliver: true,
      fastDeliveryUsername: deliveryUsername,
      status: 'غير مستلم',
    });

    // Fetch slow orders (based on individual items)
    const slowOrders = await Order.find({
      deliveryType: 'slow',
      'items.itemTaken': 'taken',
      'items.deliveryUsername': deliveryUsername,
      'items.itemStatus': 'undelivered',
    }).select('items');

    // Extract relevant slow items
    const slowItems = [];
    for (const order of slowOrders) {
      const filteredItems = order.items.filter(
        (item) =>
          item.itemTaken === 'taken' &&
          item.deliveryUsername === deliveryUsername &&
          item.itemStatus === 'undelivered'
      );
      slowItems.push(...filteredItems);
    }
console.log(fastOrders);
console.log(slowItems);
    // Respond with the combined data
    res.status(200).json({
      fastOrders,
      slowItems,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};


