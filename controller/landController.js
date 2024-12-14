// landController.js

const Land = require('../model/land'); // adjust the path if needed

// Controller function to add new land entry
exports.addLand = async (req, res) => {
    try {
        const {
            image,
            username,
            landName,
            cropType,
            workerWages,
            landSpace,
            numOfWorkers,
            city,
            location,
            coordinates,
            startDate,
            endDate,
            startTime,
            endTime
        } = req.body;
        console.log(req.body);

        // Validate required fields
        if (!username || !landName || !cropType || !workerWages || !landSpace || !numOfWorkers || !city || !location || !startDate || !endDate || !startTime || !endTime) {
            return res.status(400).json({ message: "All required fields must be provided" });
        }

        // Create a new land entry
        const newLand = new Land({
            image,
            username,
            landName,
            cropType,
            workerWages,
            landSpace,
            numOfWorkers,
            city,
            location,
            coordinates,
            startDate: new Date(startDate), // Convert to Date object if needed
            endDate: new Date(endDate),     // Convert to Date object if needed
            startTime,
            endTime
        });

        // Save the entry to the database
        await newLand.save();
        console.log("added");
        res.status(201).json({ status: true,message: "Land entry added successfully", land: newLand });
    } catch (error) {
        console.error("Error adding land:", error);
        res.status(500).json({status: false, message: "Error adding land entry", error });
    }
};
exports.getLands = async (req, res, next) => {
    try {
        const { username } = req.params; // Extract username from URL params
        const { search, category } = req.query; // Extract search query and category from URL query parameters

        // Base filter to exclude lands by the same username
        let filter = { username: { $ne: username } };

        // Add dynamic search filter
        if (search && category) {
            const searchRegex = new RegExp(search, 'i'); // Case-insensitive regex for flexible matching

            if (category === 'crop') {
                filter.cropType = searchRegex; // Filter by crop type
            } else if (category === 'location') {
                filter.city = searchRegex; // Filter by location (city)
            }
            else if (category === 'name') {
                filter.landName = searchRegex; // Filter by location (city)
            }
        }

        // Fetch lands based on the filters
        const lands = await Land.find(filter);

        res.status(200).json({ status: true, lands });
    } catch (err) {
        console.error("---> Error fetching lands -->", err);
        next(err);
    }
};
exports.getOwnerlands = async (req, res) => {
    const { username } = req.params; // Retrieve username from the request body
    console.log("Received username:", username);
  
    if (!username) {
      return res.status(400).json({ status: false, message: "Username is required" });
    }
  
    try {
      const lands = await Land.find({ username });
      if (!lands || lands.length === 0) {
        return res.status(404).json({ message: "No lands found for this owner." });
      }
      res.status(200).json({
        status: true,
        message: 'Lands retrieved successfully',
        lands,
      });
    } catch (error) {
      res.status(500).json({
        status: false,
        message: 'Error fetching Lands',
        error,
      });
    }
  };
  
exports.updateLand = async (req, res, next) => {
    try {
        const landId = req.params.landId; // Get the land ID from the URL params

        // Find the land by landId
        const land = await Land.findById(landId);

        if (!land) {
            console.log("No land found with this ID.");
            return res.status(404).json({ message: "Land not found" }); // Use 404 for not found
        }

        // Destructure the fields from the request body
        const {
            landName,
            image,
            cropType,
            workerWages,
            landSpace,
            numOfWorkers,
            city,
            location,
            startDate,
            endDate,
            startTime,
            endTime
        } = req.body;

        // Update only the fields that are provided in the request body
        if (landName) land.landName = landName;
        if (cropType) land.cropType = cropType;
        if (workerWages) land.workerWages = workerWages;
        if (landSpace) land.landSpace = landSpace;
        if (numOfWorkers) land.numOfWorkers = numOfWorkers;
        if (city) land.city = city;
        if (location) land.location = location;
        if (startDate) land.startDate = startDate;
        if (endDate) land.endDate = endDate;
        if (startTime) land.startTime = startTime;
        if (endTime) land.endTime = endTime;
        if (image) land.image = image;

        // Save the updated land information
        await land.save();

        console.log("Land updated successfully:", land);

        // Respond with the updated land information
        res.status(200).json({
            message: "Land updated successfully",
            land
        });
    } catch (error) {
        console.error("Error during land update:", error);
        return res.status(500).json({ message: "Server error" });
    }
};
exports.deleteLand = async (req, res) => {
    try {
      const { landId } = req.params;
  
      // Validation: Check if username is provided
      if (!landId) {
        return res.status(400).json({
          success: false,
          message: 'Username is required',
        });
      }
  
      // Delete all cart entries for the given username
      const result = await Land.deleteMany({ _id: landId });
  
      res.status(200).json({
        success: true,
        message: `land deleted`,
         // Number of rows deleted
      });
    } catch (error) {
      console.error('Error deleting land:', error);
      res.status(500).json({
        success: false,
        message: 'Server error. Could not delete user cart.',
      });
    }
  };
  
  exports.updateWorkerNumber = async (req, res) => {
    const { landId } = req.params; // Retrieve request ID and status from the request body
    //const currentDate = moment().format('YYYY-MM-DD HH:mm:ss'); // Get the current date and time in a specific format

    if (!landId ) {
        return res.status(400).json({ status: false, message: "Request ID and status are required" });
    }

    try {
        // Find the work request by ID
        const land = await Land.findById(landId);
        if (!land) {
            return res.status(404).json({ status: false, message: "Work request not found" });
        }

        // Determine the new status and apply the relevant changes
        else{
            land.numOfWorkers =land.numOfWorkers-1 ;
        
        }

        // Save the updated work request
        await land.save();

        res.status(200).json({
            status: true,
            message: `workers updated`,
            land,
        });
    } catch (error) {
        res.status(500).json({
            status: false,
            message: 'Error updating land workers ',
            error,
        });
    }
};
exports.getLand = async (req, res, next) => {
    try {
        console.log("in landd");
        const { landId } = req.params;

        // Fetch the land document by its ID
        const land = await Land.findById(landId);

        if (!land) {
            console.log("noland");
            return res.status(404).json({ status: false, message: "Land not found" });
        }

        // Destructure the fields you want to send from the land object
        const {
            image,
            username,
            landName,
            cropType,
            workerWages,
            landSpace,
            numOfWorkers,
            city,
            location,
            startDate,
            endDate,
            startTime,
            endTime,
            publishingDate,
        } = land;

        // Send the fields directly in the response
        res.status(200).json({
            status: true,
            image,
            username,
            landName,
            cropType,
            workerWages,
            landSpace,
            numOfWorkers,
            city,
            location,
            startDate,
            endDate,
            startTime,
            endTime,
            publishingDate,
        });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);
    }
};

  
exports.getLandStatistics = async (req, res) => {
    try {
      const totalLands = await Land.countDocuments();
      const stats = await Land.aggregate([
        { $group: { _id: "$city", count: { $sum: 1 } } },
        { $project: { city: "$_id", count: 1, percentage: { $multiply: [{ $divide: ["$count", totalLands] }, 100] } } },
      ]);
      res.json(stats);
    } catch (error) {
      res.status(500).json({ message: "Server error", error });
    }
  };
  
