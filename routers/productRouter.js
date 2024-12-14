const router = require("express").Router();
const productController = require('../controller/productsController');
router.post('/addProduct', productController.addProduct);
router.get('/getProducts1/:username', productController.getProducts1);
router.get('/getProducts2/:username', productController.getProducts2);
router.get('/getProducts3/:username', productController.getProducts3);
router.post('/updateProductQuantities', productController.updateProductQuantities);
router.post('/updateProductRate', productController.updateRate);
router.get('/getOwnerProducts/:username', productController.getOwnerproducts);
router.put('/updateProduct/:productId', productController.updateProduct);
router.delete('/deleteProduct/:productId', productController.deleteProduct);
router.get('/getProductsStatistics', productController.getProductStatistics);

module.exports = router;