const Cart = require('../model/cart');
exports.addItemToCart = async (req, res) => {
    const { username, productName,image, productId, price, quantity, quantityType } = req.body;
  
    try {
      const cartItem = new Cart({
        username,
        productName,
        image,
        productId,
        price,
        quantity,
        quantityType,
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
  