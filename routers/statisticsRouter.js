const router = require("express").Router();
const statController = require('../controller/statistics');

router.get('/getAllStatistics', statController.getOverallStatistics);
router.get('/getAllLands', statController.getAllLands);
router.get('/getAllLines', statController.getAllLines);
router.get('/getAllProducts', statController.getAllProducts);

module.exports = router;
