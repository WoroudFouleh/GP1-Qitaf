const router = require("express").Router();
const ProductAdController = require('../controller/productAdsController');
router.get('/getProductAds', ProductAdController.getAllAdvertisements);
router.post('/addProductAd', ProductAdController.addAdvertisement);
router.delete('/deleteProductAd/:id', ProductAdController.deleteAdvertisement);
router.put('/editProductAd', ProductAdController.editAdvertisement);
module.exports = router;