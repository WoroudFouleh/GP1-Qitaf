const router = require("express").Router();
const statController = require('../controller/statistics');

router.get('/getAllStatistics', statController.getOverallStatistics);
module.exports = router;
