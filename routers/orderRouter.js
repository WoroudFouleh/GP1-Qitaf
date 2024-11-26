const router = require("express").Router();
const orderController = require('../controller/orderController');
router.post('/registerOrder', orderController.registerOrder);
router.get('/getUserOrders/:username', orderController.getUserOrders);
module.exports = router;