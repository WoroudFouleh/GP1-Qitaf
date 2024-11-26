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
        const {username}=req.params;
        const productionLines = await ProductionLine.find({ 
            ownerUsername: { $ne: username }  });
        res.status(200).json({ status: true, productionLines });
    } catch (err) {
        console.log("---> err -->", err);
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
