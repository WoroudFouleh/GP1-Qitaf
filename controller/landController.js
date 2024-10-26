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
            startDate,
            endDate,
            startTime,
            endTime
        } = req.body;

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
            startDate: new Date(startDate), // Convert to Date object if needed
            endDate: new Date(endDate),     // Convert to Date object if needed
            startTime,
            endTime
        });

        // Save the entry to the database
        await newLand.save();
        res.status(201).json({ message: "Land entry added successfully", land: newLand });
    } catch (error) {
        console.error("Error adding land:", error);
        res.status(500).json({ message: "Error adding land entry", error });
    }
};
