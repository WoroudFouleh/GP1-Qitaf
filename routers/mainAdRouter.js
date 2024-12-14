const router = require("express").Router();
const MainAdController = require('../controller/mainAdsController');
router.get('/getMainAds', MainAdController.getAllAdvertisements);
router.post('/addMainAd', MainAdController.addAdvertisement);
router.delete('/deleteMainAd/:id', MainAdController.deleteAdvertisement);
router.put('/editMainAd', MainAdController.editAdvertisement);
module.exports = router;