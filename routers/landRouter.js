const router = require("express").Router();
const landController = require('../controller/landController');
router.post('/addLand', landController.addLand);
module.exports = router;