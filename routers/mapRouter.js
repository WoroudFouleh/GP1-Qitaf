const router = require("express").Router();
const mapController = require('../controller/mapLocationsController');
router.post('/addLocation', mapController.addLocation);
router.get('/getLocations', mapController.getLocations);
module.exports = router;