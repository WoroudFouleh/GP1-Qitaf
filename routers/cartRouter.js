const router = require("express").Router();
const cartController = require('../controller/cartController');
router.post('/addItemToCart', cartController.addItemToCart);
router.get('/getUserCart/:username', cartController.getUserCart);
router.delete('/deleteItemFromCart/:id', cartController.removeItemFromCart);
router.delete('/deleteUserCart/:username', cartController.deleteUserCart);
module.exports = router;
