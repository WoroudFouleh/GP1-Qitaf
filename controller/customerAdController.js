const CustomerAd = require('../model/customerAd'); // Import the model

// Controller to get all advertisements
exports.getAllAds = async (req, res) => {
    try {
        const ads = await CustomerAd.find(); // Retrieve all advertisements
        res.status(200).json({ status: true, ads });
    } catch (error) {
        res.status(500).json({ status: false, message: 'Error fetching ads', error });
    }
};

// Controller to add a new advertisement
exports.addAd = async (req, res) => {
    try {
        const { title, text, buttonText, image } = req.body;

        // Check for missing fields
        if (!title || !text || !buttonText || !image) {
            return res.status(400).json({ status: false, message: 'All fields are required' });
        }

        const newAd = new CustomerAd({ title, text, buttonText, image });
        await newAd.save();

        res.status(201).json({ status: true, message: 'Ad created successfully', ad: newAd });
    } catch (error) {
        res.status(500).json({ status: false, message: 'Error adding ad', error });
    }
};

// Controller to delete an advertisement by ID
exports.deleteAd = async (req, res) => {
    try {
        const { id } = req.params;

        const ad = await CustomerAd.findByIdAndDelete(id);
        if (!ad) {
            return res.status(404).json({ status: false, message: 'Ad not found' });
        }

        res.status(200).json({ status: true, message: 'Ad deleted successfully', ad });
    } catch (error) {
        res.status(500).json({ status: false, message: 'Error deleting ad', error });
    }
};

// Controller to edit an advertisement by ID
exports.editAd = async (req, res) => {
    try {
        
        const { id, text, image } = req.body;
console.log("here1");
        // Check for missing fields
        if ( !text || !image) {
            console.log("here2");
            return res.status(400).json({ status: false, message: 'All fields are required' });
        }

        const updatedAd = await CustomerAd.findByIdAndUpdate(
            id,
            {  text, image },
            { new: true, runValidators: true } // Return the updated document
        );
        console.log("here3");
        if (!updatedAd) {
            return res.status(404).json({ status: false, message: 'Ad not found' });
        }
        console.log("here4");
        res.status(200).json({ status: true, message: 'Ad updated successfully', ad: updatedAd });
    } catch (error) {
        res.status(500).json({ status: false, message: 'Error updating ad', error });
    }
};

