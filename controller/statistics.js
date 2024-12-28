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
  