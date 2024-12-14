const router = require("express").Router();
const CustomerAdController = require('../controller/customerAdController');
router.get('/getCustomerAds', CustomerAdController.getAllAds);
router.post('/addCustomerAd', CustomerAdController.addAd);
router.delete('/deleteCustomerAd/:id', CustomerAdController.deleteAd);
router.put('/editCustomerAd', CustomerAdController.editAd);
module.exports = router;