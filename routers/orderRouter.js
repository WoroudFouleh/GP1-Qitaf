const router = require("express").Router();
const orderController = require('../controller/orderController');
router.post('/registerOrder', orderController.registerOrder);
router.get('/getUserOrders/:username', orderController.getUserOrders);
router.post('/getDeliveryGroups', orderController.groupItems);

router.post('/getFastDeliveries', orderController.getAllOrdersWithPaths);
module.exports = router;