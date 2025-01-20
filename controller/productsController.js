const Product = require('../model/product'); // Adjust the path as necessary

exports.addProduct = async (req, res, next) => {
    try {
        console.log("---req body---", req.body);

        const {
            image,
            username,
            name,
            type,
            quantity,
            quantityType,
            price,
            city,
            location,
            coordinates,
            description,
            preparationTime,
            preparationTimeUnit
        } = req.body;


        const product = new Product({
            image,
            username,
            name,
            type,
            quantity,
            quantityType,
            price,
            city,
            location,
            coordinates,
            description,
            rate:5,
            preparationTime,
            preparationTimeUnit
        });

        await product.save();


        res.status(201).json({ status: true, success: 'Product added successfully', product });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);  
    }
};
exports.getProducts1 = async (req, res, next) => {
  try {
    const { username } = req.params; // Extract username from URL params
    const { search } = req.query; // Extract search query

    // Base filter to exclude products by the same username and check quantity > 0
    let filter = { type: "محصول", username: { $ne: username }, quantity: { $gt: 0 } };

    // Add dynamic search filter
    if (search) {
      const searchRegex = new RegExp(search, 'i'); // Case-insensitive regex for flexible matching
      filter.name = searchRegex; // Filter by product name
    }

    // Fetch products based on the filters
    const products = await Product.find(filter);

    res.status(200).json({ status: true, products });
  } catch (err) {
    console.error("---> Error fetching products -->", err);
    next(err);
  }
};

exports.getProducts2 = async (req, res, next) => {
  try {
    const { username } = req.params; // Extract username from URL params
    const { search } = req.query; // Extract search query

    // Base filter to exclude products by the same username and check quantity > 0
    let filter = { type: "منتج غذائي", username: { $ne: username }, quantity: { $gt: 0 } };

    // Add dynamic search filter
    if (search) {
      const searchRegex = new RegExp(search, 'i'); // Case-insensitive regex for flexible matching
      filter.name = searchRegex; // Filter by product name
    }

    // Fetch products based on the filters
    const products = await Product.find(filter);

    res.status(200).json({ status: true, products });
  } catch (err) {
    console.error("---> Error fetching products -->", err);
    next(err);
  }
};

exports.getProducts3 = async (req, res, next) => {
  try {
    const { username } = req.params; // Extract username from URL params
    const { search } = req.query; // Extract search query

    // Base filter to exclude products by the same username and check quantity > 0
    let filter = { type: "منتج غير غذائي", username: { $ne: username }, quantity: { $gt: 0 } };

    // Add dynamic search filter
    if (search) {
      const searchRegex = new RegExp(search, 'i'); // Case-insensitive regex for flexible matching
      filter.name = searchRegex; // Filter by product name
    }

    // Fetch products based on the filters
    const products = await Product.find(filter);

    res.status(200).json({ status: true, products });
  } catch (err) {
    console.error("---> Error fetching products -->", err);
    next(err);
  }
};



exports.updateProductQuantities = async (req, res) => {
  try {
    const { items } = req.body;

    // Validation
    if (!items || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Items list is required',
      });
    }

    for (const item of items) {
      const product = await Product.findById(item.productId);

      if (!product) {
        return res.status(404).json({
          success: false,
          message: `Product with ID ${item.productId} not found`,
        });
      }

      if (product.quantity < item.quantity) {
        return res.status(400).json({
          success: false,
          message: `Insufficient stock for product "${product.name}". Available: ${product.quantity}, Requested: ${item.quantity}`,
        });
      }

      // Deduct the quantity
      product.quantity -= item.quantity;

      // Save the updated product
      await product.save();
    }

    res.status(200).json({
      success: true,
      message: 'Product quantities updated successfully',
    });
  } catch (error) {
    console.error('Error updating product quantities:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Server error. Could not update product quantities',
    });
  }
};
const mongoose = require('mongoose');

exports.updateRate = async (req, res, next) => {
    try {
        const { productId, newRate } = req.body;
        console.log("Received productId:", productId);

        // Validate the productId format
        if (!mongoose.Types.ObjectId.isValid(productId)) {
            console.log("here");
            return res.status(400).json({ status: false, error: "Invalid Product ID format" });
        }

        // Validate the new rate (it should be between 1 and 5)
        if (newRate < 1 || newRate > 5) {
            return res.status(400).json({ status: false, error: "Rate must be between 1 and 5" });
        }

        // Convert newRate to an integer
        const newRateInt = Math.round(newRate);

        // Convert productId to ObjectId
        const objectId = new mongoose.Types.ObjectId(productId);

        // Find the product
        const product = await Product.findById(objectId);

        if (!product) {
            return res.status(404).json({ status: false, error: "Product not found" });
        }

        // Calculate new average rate
        const totalRating = product.rate + newRateInt;
        product.rateCount += 1; // Increment count
        product.rate = totalRating / 2; // Update average rate

        // Save the updated product
        await product.save();

        res.status(200).json({
            status: true,
            success: "Product rating updated successfully",
            product: {
                id: product._id,
                name: product.name,
                rate: product.rate,
            }
        });
    } catch (err) {
        console.error("---> Error in updating rate --->", err);
        next(err);
    }
};
exports.getOwnerproducts = async (req, res) => {
    const { username } = req.params; // Retrieve username from the request body
    console.log("Received username:", username);
  
    if (!username) {
      return res.status(400).json({ status: false, message: "Username is required" });
    }
  
    try {
      const products = await Product.find({ username });
      if (!products || products.length === 0) {
        return res.status(404).json({ message: "No products found for this owner." });
      }
      res.status(200).json({
        status: true,
        message: 'products retrieved successfully',
        products,
      });
    } catch (error) {
      res.status(500).json({
        status: false,
        message: 'Error fetching products',
        error,
      });
    }
  };
  exports.updateProduct = async (req, res, next) => {
    try {
        const productId = req.params.productId; // Get the product ID from the URL params

        // Find the product by productId
        const product = await Product.findById(productId);

        if (!product) {
            console.log("No product found with this ID.");
            return res.status(404).json({ message: "Product not found" }); // Use 404 for not found
        }

        // Destructure the fields from the request body
        const {
            image,
            name,
            type,
            quantity,
            quantityType,
            price,
            city,
            location,
            description,
            preparationTime,
            preparationTimeUnit
        } = req.body;

        // Update only the fields that are provided in the request body
        if (image) product.image = image;
        if (name) product.name = name;
        if (type) product.type = type;
        if (quantity) product.quantity = quantity;
        if (quantityType) product.quantityType = quantityType;
        if (price) product.price = price;
        if (city) product.city = city;
        if (location) product.location = location;
        if (description) product.description = description;
        if (preparationTime) product.preparationTime = preparationTime;
        if (preparationTimeUnit) product.preparationTimeUnit = preparationTimeUnit;

        // Save the updated product information
        await product.save();

        console.log("Product updated successfully:", product);

        // Respond with the updated product information
        res.status(200).json({
            status: true,
            message: "Product updated successfully",
            product
        });
    } catch (error) {
        console.error("Error during product update:", error);
        return res.status(500).json({ message: "Server error" });
    }
};

exports.deleteProduct = async (req, res) => {
    try {
      const { productId } = req.params;
  
      // Validation: Check if username is provided
      if (!productId) {
        return res.status(400).json({
          success: false,
          message: 'Username is required',
        });
      }
  
      // Delete all cart entries for the given username
      const result = await Product.deleteMany({ _id: productId });
  
      res.status(200).json({
        success: true,
        message: `product deleted`,
         // Number of rows deleted
      });
    } catch (error) {
      console.error('Error deleting product:', error);
      res.status(500).json({
        success: false,
        message: 'Server error. Could not delete user cart.',
      });
    }
  };
  exports.getProductStatistics = async (req, res) => {
    try {
      const totalProducts = await Product.countDocuments();
      const stats = await Product.aggregate([
        { $group: { _id: "$type", count: { $sum: 1 } } },
        { $project: { category: "$_id", count: 1, percentage: { $multiply: [{ $divide: ["$count", totalProducts] }, 100] } } },
      ]);
      res.json(stats);
    } catch (error) {
      res.status(500).json({ message: "Server error", error });
    }
  };
  


