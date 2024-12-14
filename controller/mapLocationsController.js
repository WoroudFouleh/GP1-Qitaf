const Map = require('../model/mapLocations'); // adjust the path if needed

// Controller function to add new land entry
exports.addLocation = async (req, res) => {
    try {
        const {
            locationName,
            coordinates,
        } = req.body;
        console.log(req.body);

        // Validate required fields
        if (!locationName || !coordinates ) {
            return res.status(400).json({ message: "All required fields must be provided" });
        }

        // Create a new land entry
        const newLocation = new Map({
            locationName,
            coordinates
            
        });

        // Save the entry to the database
        await Map.save();
        console.log("added");
        res.status(201).json({ status: true,message: "location entry added successfully", land: newLand });
    } catch (error) {
        console.error("Error adding location:", error);
        res.status(500).json({status: false, message: "Error adding land entry", error });
    }
};
exports.getLocations = async (req, res) => {
    try {
      const locations = await Map.find({}); // Fetch all locations
  
      if (!locations.length) {
        return res.status(404).json({ status: false,message: 'No locations found.' });
      }
  
      res.status(200).json({status: true,locations});
    } catch (error) {
      console.error('Error fetching locations:', error);
      res.status(500).json({ status: false, message: 'An error occurred while fetching locations.', error });
    }
  };