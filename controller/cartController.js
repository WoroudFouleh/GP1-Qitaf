const Cart = require('../model/cart');
exports.addItemToCart = async (req, res) => {
    const {ownerusername, username, productName,image, productId, price, quantity, quantityType, productCity, productCoordinates } = req.body;
  
    try {
      const cartItem = new Cart({
        ownerusername,
        username,
        productName,
        image,
        productId,
        price,
        quantity,
        quantityType,
        productCity,
        productCoordinates
      });
  
      await cartItem.save();
      res.status(201).json({ 
        status: true,
        message: 'Item added to cart', cartItem });
    } catch (error) {
      res.status(500).json({
        status: false,
         message: 'Error adding item to cart', error });
    }
  };



// Controller function
exports.getUserCart = async (req, res) => {
  const { username } = req.params; // Retrieve username from the request body
  console.log("Received username:", username);

  if (!username) {
    return res.status(400).json({ status: false, message: "Username is required" });
  }

  try {
    const cartItems = await Cart.find({ username });
    res.status(200).json({
      status: true,
      message: 'Cart retrieved successfully',
      cartItems,
    });
  } catch (error) {
    res.status(500).json({
      status: false,
      message: 'Error fetching cart items',
      error,
    });
  }
};

exports.removeItemFromCart = async (req, res) => {
    const { id } = req.params;
  
    try {
      await Cart.findByIdAndDelete(id);
      res.status(200).json({ status:true,message: 'Item removed from cart' });
    } catch (error) {
      res.status(500).json({ status:false, message: 'Error removing item from cart', error });
    }
  };
  
// Function to delete user's cart
exports.deleteUserCart = async (req, res) => {
  try {
    const { username } = req.params;

    // Validation: Check if username is provided
    if (!username) {
      return res.status(400).json({
        success: false,
        message: 'Username is required',
      });
    }

    // Delete all cart entries for the given username
    const result = await Cart.deleteMany({ username });

    res.status(200).json({
      success: true,
      message: `Cart cleared for user: ${username}`,
      deletedCount: result.deletedCount, // Number of rows deleted
    });
  } catch (error) {
    console.error('Error deleting user cart:', error);
    res.status(500).json({
      success: false,
      message: 'Server error. Could not delete user cart.',
    });
  }
};