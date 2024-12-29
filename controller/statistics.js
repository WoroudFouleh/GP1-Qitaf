const Product = require('../model/product');
const ProductionLine = require('../model/productionLine'); // Path to your ProductionLine model
const User = require('../model/user');
const Land = require('../model/land'); // adjust the path if needed
const DeliveryMan = require('../model/deliveryMan'); // adjust the path if needed
exports.getOverallStatistics = async (req, res) => {
    try {
        const usersCount = await User.countDocuments({ userType: 1 }); // Count users with type = 2
        const landownersCount = await User.countDocuments({ userType: 2 }); // Count users with type = 1
        
      const deliveryMenCount = await DeliveryMan.countDocuments();
      const landsCount = await Land.countDocuments();
      const productsCount = await Product.countDocuments();
      const productionLinesCount = await ProductionLine.countDocuments();
  
      res.json({
        users: usersCount,
        landowners: landownersCount,
        deliveryMen: deliveryMenCount,
        lands: landsCount,
        products: productsCount,
        productionLines: productionLinesCount,
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error });
    }
  };
  exports.getAllLands = async (req, res) => {
      try {
        const lands = await Land.find();
        res.status(200).json({ status: true,lands });
      } catch (error) {
        console.error('Error fetching delivery men:', error);
        res.status(500).json({status: false, message: 'Internal Server Error' });
      }
    };
    exports.getAllLines = async (req, res) => {
      try {
        const lines = await ProductionLine.find();
        res.status(200).json({ status: true,lines });
      } catch (error) {
        console.error('Error fetching delivery men:', error);
        res.status(500).json({status: false, message: 'Internal Server Error' });
      }
    };
    exports.getAllProducts = async (req, res) => {
      try {
        const products = await Product.find();
        res.status(200).json({ status: true,products });
      } catch (error) {
        console.error('Error fetching delivery men:', error);
        res.status(500).json({status: false, message: 'Internal Server Error' });
      }
    };