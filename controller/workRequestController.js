const WorkRequest = require('../model/workRequest'); // Assuming the schema is in models/WorkRequest.js
//const Land = require('../models/Land'); // Assuming you have a Land model

// Function to register a work request
exports.registerRequest = async (req, res) => {
  try {
    const {
      ownerUsername,
      workerUsername,
      workerCity,
      workerGender,
      workerRate,
      landId,
      landName,
      landLocation,
      numOfWorkers,
      workerWage,
      workerFirstname,
      workerLastname,
      workerProfileImage
    } = req.body;

    // Validation: Ensure required fields are provided
    if (
      !ownerUsername ||
      !workerUsername ||
      !workerCity ||
      !workerGender ||
      !landId ||
      !landName ||
      !landLocation ||
      !numOfWorkers ||
      !workerWage
    ) {
      return res.status(400).json({ status:false,
        error: 'All fields are required.' });
    }

    // Check if the referenced land exists
    
    // Create a new work request
    const newRequest = new WorkRequest({
      ownerUsername,
      workerUsername,
      workerFirstname,
      workerLastname,
      workerProfileImage,
      workerCity,
      workerGender,
      workerRate,
      landId,
      landName,
      landLocation,
      numOfWorkers,
      workerWage,
      requestStatus: 'pending', 
      // Default status
    });

    // Save the request in the database
    await newRequest.save();

    return res.status(201).json({
        status:true,
      message: 'Work request registered successfully.',
      request: newRequest,
    });
  } catch (error) {
    
    console.error('Error registering work request:', error);
    return res.status(500).json({ status:false,
        error: 'Internal server error.' });
  }
};
exports.getOwnerRequests = async (req, res) => {
    const { ownerUsername } = req.params; // Retrieve username from the request body
    console.log("Received username:", ownerUsername);
  
    if (!ownerUsername) {
      return res.status(400).json({ status: false, message: "Username is required" });
    }
  
    try {
      const requests = await WorkRequest.find({ ownerUsername,
        requestStatus: 'pending'
       });
      if (!requests || requests.length === 0) {
        return res.status(404).json({ message: "No requests found for this owner." });
      }
      res.status(200).json({
        status: true,
        message: 'requests retrieved successfully',
        requests,
      });
    } catch (error) {
      res.status(500).json({
        status: false,
        message: 'Error fetching requests',
        error,
      });
    }
  };
//const moment = require('moment'); // for handling date formatting, if you want to use a library like moment.js

exports.updateWorkRequestStatus = async (req, res) => {
    const { requestId, status } = req.body; // Retrieve request ID and status from the request body
    //const currentDate = moment().format('YYYY-MM-DD HH:mm:ss'); // Get the current date and time in a specific format

    if (!requestId || !status) {
        return res.status(400).json({ status: false, message: "Request ID and status are required" });
    }

    try {
        // Find the work request by ID
        const workRequest = await WorkRequest.findById(requestId);
        if (!workRequest) {
            return res.status(404).json({ status: false, message: "Work request not found" });
        }

        // Determine the new status and apply the relevant changes
        if (status === 'accepted') {
            // Update request status to accepted
            workRequest.requestStatus = 'accepted';
            // Decrease the number of workers by 1 (if it's greater than 0)
            if (workRequest.numOfWorkers > 0) {
                workRequest.numOfWorkers -= 1;
            }
            // Set the owner decision date to the current date
            // workRequest.ownerDecisionDate = Date.now;
        } else if (status === 'rejected') {
            // Update request status to rejected
            workRequest.requestStatus = 'rejected';
            // Set the owner decision date to the current date
            // workRequest.ownerDecisionDate = Date.now;
        } else {
            return res.status(400).json({ status: false, message: "Invalid status, should be 'accepted' or 'rejected'" });
        }

        // Save the updated work request
        await workRequest.save();

        res.status(200).json({
            status: true,
            message: `Request ${status} successfully`,
            workRequest,
        });
    } catch (error) {
        res.status(500).json({
            status: false,
            message: 'Error updating work request status',
            error,
        });
    }
};

exports.getWorkerRequests = async (req, res) => {
    const { workerUsername } = req.params; // Retrieve username from the request body
    console.log("Received username:", workerUsername);
  
    if (!workerUsername) {
      return res.status(400).json({ status: false, message: "Username is required" });
    }
  
    try {
      const requests = await WorkRequest.find({ workerUsername:workerUsername
        
       });
      if (!requests || requests.length === 0) {
        return res.status(404).json({ message: "No requests found for this worker." });
      }
      res.status(200).json({
        status: true,
        message: 'requests retrieved successfully',
        requests,
      });
    } catch (error) {
      res.status(500).json({
        status: false,
        message: 'Error fetching requests',
        error,
      });
    }
  }; 

  exports.deleteWorkRequest = async (req, res) => {
    const { id } = req.params;
    console.log("d1");
    try {
      await WorkRequest.findByIdAndDelete(id);
      res.status(200).json({ status:true,message: 'request removed ' });
    console.log("deleted");
    } catch (error) {
        console.log(error);
      res.status(500).json({ status:false, message: 'Error removing request ', error });
    }
  };

  exports.getLandWorkers = async (req, res) => {
    const { landId } = req.params; // Retrieve username from the request body
    console.log("Received landId:", landId);
  
    if (!landId) {
      return res.status(400).json({ status: false, message: "Username is required" });
    }
  
    try {
      const requests = await WorkRequest.find({ landId, 
      requestStatus: 'accepted'
       });
      if (!requests || requests.length === 0) {
        return res.status(404).json({ message: "No requests found for this owner." });
      }
      res.status(200).json({
        status: true,
        message: 'requests retrieved successfully',
        requests,
      });
    } catch (error) {
      res.status(500).json({
        status: false,
        message: 'Error fetching requests',
        error,
      });
    }
  };