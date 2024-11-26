const router = require("express").Router();
const productionLineController = require('../controller/productionLineController');
router.post('/registerproductionLine', productionLineController.registerProductionLine);
router.get('/getProductionLines/:username', productionLineController.getProductionLines);
router.get('/getOwnerLines/:username', productionLineController.getOwnerProductionLines);
router.put('/updateProductionLine/:productionLineId', productionLineController.updateProductionLine);
router.delete('/deleteLine/:productionLineId', productionLineController.deleteLine);
module.exports = router;