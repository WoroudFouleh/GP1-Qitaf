//require('dotenv');

const express = require('express');
const bodyParser = require('body-parser');
const UserRoute = require('./routers/USERR'); // Ensure path is correct
const productRoute = require('./routers/productRouter'); // Ensure path is correct
const landRoute = require('./routers/landRouter'); // Ensure path is correct
const app = express();
app.use(bodyParser.json({ limit: '10mb' })); // You can increase '10mb' to whatever size you need
app.use(bodyParser.urlencoded({ limit: '10mb', extended: true }));

// Mounting user routes
app.use('/api/users', UserRoute);
app.use('/api/products', productRoute);
app.use('/api/lands', landRoute);
// Optional: Add a fallback route for testing
// app.get('/', (req, res) => {
//     res.send('Server is working');
// });

const port = 3000;
const host = '192.168.88.15';  // Your machine's IP address

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
