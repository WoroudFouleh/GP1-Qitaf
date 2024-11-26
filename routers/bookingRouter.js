const router = require("express").Router();
const bookingController = require('../controller/bookingController');
router.post('/addNewBooking', bookingController.registerBooking);
router.post('/getBookedTimes', bookingController.getBookedTimes);
router.get('/getOwnerBooking/:ownerUsername', bookingController.getOwnerBooking);
router.get('/getCustomerBooking/:customerUsername', bookingController.getCustomerBooking);
module.exports = router;