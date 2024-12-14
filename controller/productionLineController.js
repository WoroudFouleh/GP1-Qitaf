const productionLine = require('../model/productionLine');
const ProductionLine = require('../model/productionLine'); // Path to your ProductionLine model


exports.registerProductionLine = async (req, res) => {
  try {
    const {
      ownerUsername,
      image,
      lineName,
      materialType,
      description,
      phoneNumber,
      city,
      location,
      coordinates,
      timeOfPreparation,
      unitTimeOfPreparation,
      price,
      quantityUnit,
      startWorkTime,
      endWorkTime,
      datesOfWork,
    } = req.body;



    

    // Create a new production line
    const productionLine = new ProductionLine({
        ownerUsername,
      image,
      lineName,
      materialType,
      description,
      phoneNumber,
      city,
      location,
      coordinates,
      timeOfPreparation,
      unitTimeOfPreparation,
      price,
      quantityUnit,
      startWorkTime,
      endWorkTime,
      datesOfWork,
    });

    // Save to the database
    const savedLine = await productionLine.save();
    res.status(201).json({ status: true, message: "Production line registered successfully.", data: savedLine });
  } catch (error) {
    console.error("Error registering production line:", error);
    res.status(500).json({ status: false, message: "Internal server error." });
  }
};
exports.getProductionLines = async (req, res, next) => {
  try {
      const { username } = req.params; // Extract username from URL params
      const { search, category } = req.query; // Extract search query and category from URL query parameters

      // Base filter to exclude lands by the same username
      let filter = { username: { $ne: username } };

      // Add dynamic search filter
      if (search && category) {
          const searchRegex = new RegExp(search, 'i'); // Case-insensitive regex for flexible matching

          if (category === 'crop') {
              filter.materialType = searchRegex; // Filter by crop type
          } else if (category === 'location') {
              filter.city = searchRegex; // Filter by location (city)
          }
          else if (category === 'name') {
            filter.lineName = searchRegex; // Filter by location (city)
        }
      }

      // Fetch lands based on the filters
      const lines = await ProductionLine.find(filter);

      res.status(200).json({ status: true, lines });
  } catch (err) {
      console.error("---> Error fetching lands -->", err);
      next(err);
  }
};

exports.getOwnerProductionLines = async (req, res) => {
    const { username } = req.params; // Retrieve username from the request body
    console.log("Received username:", username);
  
    if (!username) {
      return res.status(400).json({ status: false, message: "Username is required" });
    }
  
    try {
      const lines = await productionLine.find({ ownerUsername:username });
      if (!lines || lines.length === 0) {
        return res.status(404).json({ message: "No lines found for this owner." });
      }
      res.status(200).json({
        status: true,
        message: 'lines retrieved successfully',
        lines,
      });
    } catch (error) {
      res.status(500).json({
        status: false,
        message: 'Error fetching lines',
        error,
      });
    }
  };
  exports.updateProductionLine = async (req, res, next) => {
    try {
        const productionLineId = req.params.productionLineId; // Get the production line ID from the URL params

        // Find the production line by ID
        const productionLine = await ProductionLine.findById( productionLineId);

        if (!productionLine) {
            console.log(productionLineId);
            console.log("No production line found with this ID.");
            return res.status(404).json({ message: "Production line not found" }); // Use 404 for not found
        }

        // Destructure the fields from the request body
        const {
            
            image,
            lineName,
            materialType,
            description,
            phoneNumber,
            city,
            location,
            timeOfPreparation,
            unitTimeOfPreparation,
            price,
            quantityUnit,
            startWorkTime,
            endWorkTime,
            datesOfWork
        } = req.body;

        // Update only the fields that are provided in the request body
        
        if (image) productionLine.image = image;
        if (lineName) productionLine.lineName = lineName;
        if (materialType) productionLine.materialType = materialType;
        if (description) productionLine.description = description;
        if (phoneNumber) productionLine.phoneNumber = phoneNumber;
        if (city) productionLine.city = city;
        if (location) productionLine.location = location;
        if (timeOfPreparation) productionLine.timeOfPreparation = timeOfPreparation;
        if (unitTimeOfPreparation) productionLine.unitTimeOfPreparation = unitTimeOfPreparation;
        if (price) productionLine.price = price;
        if (quantityUnit) productionLine.quantityUnit = quantityUnit;
        if (startWorkTime) productionLine.startWorkTime = startWorkTime;
        if (endWorkTime) productionLine.endWorkTime = endWorkTime;
        if (datesOfWork) productionLine.datesOfWork = datesOfWork;

        // Save the updated production line information
        await productionLine.save();

        console.log("Production line updated successfully:", productionLine);

        // Respond with the updated production line information
        res.status(200).json({
            message: "Production line updated successfully",
            productionLine
        });
    } catch (error) {
        console.error("Error during production line update:", error);
        return res.status(500).json({ message: "Server error" });
    }
};
exports.deleteLine = async (req, res) => {
    try {
      const { lineId } = req.params;
  
      // Validation: Check if username is provided
      if (!lineId) {
        return res.status(400).json({
          success: false,
          message: 'id is required',
        });
      }
  
      // Delete all cart entries for the given username
      const result = await ProductionLine.deleteMany({ _id: lineId });
  
      res.status(200).json({
        success: true,
        message: `line deleted`,
         // Number of rows deleted
      });
    } catch (error) {
      console.error('Error deleting line:', error);
      res.status(500).json({
        success: false,
        message: 'Server error. Could not delete user cart.',
      });
    }
  };
  const mongoose = require('mongoose');
  exports.updateRate = async (req, res, next) => {
    try {
        const { productionLineId, newRate } = req.body;
        console.log("Received productId:", productionLineId);

        // Validate the productId format
        if (!mongoose.Types.ObjectId.isValid(productionLineId)) {
            console.log("here");
            return res.status(400).json({ status: false, error: "Invalid Product ID format" });
        }

        // Validate the new rate (it should be between 1 and 5)
        if (newRate < 1 || newRate > 5) {
            return res.status(400).json({ status: false, error: "Rate must be between 1 and 5" });
        }

        // Convert newRate to an integer
        const newRateInt = Math.round(newRate);

        // Convert productId to ObjectId
        const objectId = new mongoose.Types.ObjectId(productionLineId);

        // Find the product
        const line = await ProductionLine.findById(objectId);

        if (!line) {
            return res.status(404).json({ status: false, error: "Product not found" });
        }

        // Calculate new average rate
        const totalRating = line.rate + newRateInt;
        line.rateCount += 1; // Increment count
        line.rate = totalRating / 2; // Update average rate

        // Save the updated product
        await line.save();

        res.status(200).json({
            status: true,
            success: "Product rating updated successfully",
            line: {
                id: line._id,
                name: line.lineName,
                rate: line.rate,
            }
        });
    } catch (err) {
        console.error("---> Error in updating rate --->", err);
        next(err);
    }
};

exports.getProductionStatistics = async (req, res) => {
  try {
    console.log("in lines");
    const totalLines = await ProductionLine.countDocuments();
    const stats = await ProductionLine.aggregate([
      { $group: { _id: "$city", count: { $sum: 1 } } },
      { $project: { city: "$_id", count: 1, percentage: { $multiply: [{ $divide: ["$count", totalLines] }, 100] } } },
    ]);
    res.json(stats);
  } catch (error) {
    res.status(500).json({ message: "Server error", error });
  }
};
