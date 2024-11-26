const router = require("express").Router();
const workRequestController = require('../controller/workRequestController');
router.post('/registerWorkRequest', workRequestController.registerRequest);
router.get('/getOwnerRequests/:ownerUsername', workRequestController.getOwnerRequests);
router.put('/requestDecision', workRequestController.updateWorkRequestStatus);
router.get('/getWorkerRequests/:workerUsername', workRequestController.getWorkerRequests);
module.exports = router;