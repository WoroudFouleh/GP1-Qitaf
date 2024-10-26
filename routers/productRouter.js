const router = require("express").Router();
const productController = require('../controller/productsController');
router.post('/addProduct', productController.addProduct);
module.exports = router;