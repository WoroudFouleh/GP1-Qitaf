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
exports.getProducts1 = async (req, res, next) => {
    try {
        const products = await Product.find({ type: "محصول" });
        res.status(200).json({ status: true, products });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);  
    }
};
exports.getProducts2 = async (req, res, next) => {
    try {
        const products = await Product.find({ type: "منتج غذائي" });
        res.status(200).json({ status: true, products });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);  
    }
};
exports.getProducts3 = async (req, res, next) => {
    try {
        const products = await Product.find({ type: "منتج غير غذائي" });
        res.status(200).json({ status: true, products });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);  
    }
};
