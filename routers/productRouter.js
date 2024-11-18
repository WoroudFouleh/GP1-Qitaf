const router = require("express").Router();
const productController = require('../controller/productsController');
router.post('/addProduct', productController.addProduct);
router.get('/getProducts1', productController.getProducts1);
router.get('/getProducts2', productController.getProducts2);
router.get('/getProducts3', productController.getProducts3);
module.exports = router;