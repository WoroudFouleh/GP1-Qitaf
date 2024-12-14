const router = require("express").Router();
const UserController = require('../controller/UserController');
router.post('/register',UserController.register);
router.post('/login', UserController.login);
router.post('/forgotPass', UserController.forgotPassword);
router.post('/verifyCode', UserController.verifyCode);
router.patch('/updatePassword/:username', UserController.updatePassword);
router.put('/updateUser/:username', UserController.updateUser);
router.post('/verifyPassword', UserController.verifyPassword);
router.get('/getUser/:username', UserController.getUserInfo);
router.post('/updatePostsCount/:username', UserController.updateUserPosts);
router.post('/rateWorker', UserController.rateWorker);
router.get('/getUserStatistics', UserController.getUserStatistics);

module.exports = router;

