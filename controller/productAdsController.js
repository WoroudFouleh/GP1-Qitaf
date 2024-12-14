const ProductAd = require('../model/productAdvertisements');

exports.getAllAdvertisements = async (req, res) => {
    try {
        const ads = await ProductAd.find().sort({ publishingDate: -1 }); // Sort by most recent
        res.status(200).json({ status: true, message: 'Advertisements retrieved successfully', ads });
    } catch (error) {
        console.error('Error fetching advertisements:', error);
        res.status(500).json({ status: false, message: 'Server error' });
    }
};
// Add Advertisement
exports.addAdvertisement = async (req, res) => {
    try {
        const { image } = req.body;

        if (!image) {
            return res.status(400).json({status: false, message: 'Image is required' });
        }

        const newAd = new ProductAd({ image });
        await newAd.save();

        res.status(201).json({status: true, message: 'Advertisement added successfully', ad: newAd });
    } catch (error) {
        console.error('Error adding advertisement:', error);
        res.status(500).json({status: false, message: 'Server error' });
    }
};

// Delete Advertisement
exports.deleteAdvertisement = async (req, res) => {
    try {
        const { id } = req.params;

        const deletedAd = await ProductAd.findByIdAndDelete(id);
        if (!deletedAd) {
            return res.status(404).json({status: false, message: 'Advertisement not found' });
        }

        res.status(200).json({status: true, message: 'Advertisement deleted successfully', ad: deletedAd });
    } catch (error) {
        console.error('Error deleting advertisement:', error);
        res.status(500).json({status: false, message: 'Server error' });
    }
};
exports.editAdvertisement = async (req, res) => {
    try {
        
        const { id, image } = req.body;

        if (!image) {
            return res.status(400).json({ status: false, message: 'Image is required' });
        }

        const updatedAd = await ProductAd.findByIdAndUpdate(
            id,
            { image },
            { new: true, runValidators: true }
        );

        if (!updatedAd) {
            return res.status(404).json({ status: false, message: 'Advertisement not found' });
        }

        res.status(200).json({ status: true, message: 'Advertisement updated successfully', ad: updatedAd });
    } catch (error) {
        console.error('Error updating advertisement:', error);
        res.status(500).json({ status: false, message: 'Server error' });
    }
};

