//require('dotenv');

const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const UserRoute = require('./routers/USERR'); // Ensure path is correct
const productRoute = require('./routers/productRouter'); // Ensure path is correct
const landRoute = require('./routers/landRouter'); // Ensure path is correct
const cartRoute = require('./routers/cartRouter');
const orderRoute = require('./routers/orderRouter');
const workRequestRoute = require('./routers/workRequestRouter');
const productionLineRoute = require('./routers/productionLineRouter');
const bookingRoute = require('./routers/bookingRouter');
const mapRoute = require('./routers/mapRouter');
const postRoute = require('./routers/postRouter');
const statisticRoute = require('./routers/statisticsRouter');
const mainAdsRoute = require('./routers/mainAdRouter');
const productAdsRoute = require('./routers/prodAdRouter');
const customerAdsRoute = require('./routers/customerAdRouter');
const deliveryWorkRoute = require('./routers/deliveryWorkRouter');
const app = express();
app.use(bodyParser.json({ limit: '10mb' })); // You can increase '10mb' to whatever size you need
app.use(bodyParser.urlencoded({ limit: '10mb', extended: true }));

// Mounting user routes
app.use('/api/users', UserRoute);
app.use('/api/products', productRoute);
app.use('/api/lands', landRoute);
app.use('/api/carts', cartRoute);
app.use('/api/orders', orderRoute);
app.use('/api/workRequests', workRequestRoute);
app.use('/api/productionLines', productionLineRoute);
app.use('/api/bookings', bookingRoute);
app.use('/api/maps', mapRoute);
app.use('/api/posts', postRoute);
app.use('/api/statistics', statisticRoute);
app.use('/api/mainAds', mainAdsRoute);
app.use('/api/productAds', productAdsRoute);
app.use('/api/customerAds', customerAdsRoute);
app.use('/api/deliveryWorks', deliveryWorkRoute);
app.use('/uploads/', express.static(path.join(__dirname, 'uploads')));

const port = 3000;
const host = '192.168.88.7';  // Your machine's IP address

const server = app.listen(port, host, () => {
    console.log(`App listening at http://${host}:${port}/`);
});

// Set up Socket.IO
const io = require('socket.io')(server, {
    pingTimeout: 60000,
    cors: {
        origin: `http://${host}:${port}`,  // Allow connections from the same IP and port
        methods: ["GET", "POST"],
        credentials: true
    }
});



module.exports = app;
