const Product = require('../model/product'); // Adjust the path as necessary

exports.addProduct = async (req, res, next) => {
    try {
        console.log("---req body---", req.body);

        const {
            image,
            username,
            name,
            type,
            quantity,
            quantityType,
            price,
            city,
            location,
            description
        } = req.body;


        const product = new Product({
            image,
            username,
            name,
            type,
            quantity,
            quantityType,
            price,
            city,
            location,
            description
        });

        await product.save();


        res.status(201).json({ status: true, success: 'Product added successfully', product });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);  
    }
};
