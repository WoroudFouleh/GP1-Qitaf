//require('dotenv');

const express = require('express');
const bodyParser = require('body-parser');
const UserRoute = require('./routers/USERR'); // Ensure path is correct
const productRoute = require('./routers/productRouter'); // Ensure path is correct
const landRoute = require('./routers/landRouter'); // Ensure path is correct
const cartRoute = require('./routers/cartRouter');
const orderRoute = require('./routers/orderRouter');
const workRequestRoute = require('./routers/workRequestRouter');
const productionLineRoute = require('./routers/productionLineRouter');
const bookingRoute = require('./routers/bookingRouter');
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
// Optional: Add a fallback route for testing
// app.get('/', (req, res) => {
//     res.send('Server is working');
// });

const port = 3000;
const host = '172.23.16.118';  // Your machine's IP address

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
