const router = require("express").Router();
const paymentController = require('../controller/payment');
router.post('/createPayment', paymentController.createPayment);
module.exports = router;