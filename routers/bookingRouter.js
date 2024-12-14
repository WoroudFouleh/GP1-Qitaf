const router = require("express").Router();
const bookingController = require('../controller/bookingController');
router.post('/addNewBooking', bookingController.registerBooking);
router.post('/getBookedTimes', bookingController.getBookedTimes);
router.get('/getOwnerBooking/:ownerUsername', bookingController.getOwnerBooking);
router.get('/getCustomerBooking/:customerUsername', bookingController.getCustomerBooking);
router.delete('/deleteBooking/:id', bookingController.deleteBooking);
router.put('/bookingDecision', bookingController.updatebookingStatus);
module.exports = router;