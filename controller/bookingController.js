
const Booking = require('../model/booking');

exports.registerBooking =async (req, res) => {
  try {
    // Destructure data from the request body
    const {
      lineId,
      lineName,
      customerUsername,
      userPhone,
      userImage,
      userFirstName,
      userLastName,
      ownerUsername,
      quantity,
      date,
      startTime,
      endTime,
      totalPrice,
      revenuePrice,
      cropType
    } = req.body;

    // Validate the incoming data (example validation checks)
    if (!lineId || !customerUsername || !userPhone || !ownerUsername || !quantity || !startTime || !endTime || !totalPrice || !revenuePrice) {
      return res.status(400).json({ message: 'All fields are required.' });
    }

    // Ensure the lineId exists in the Line collection
    

    // Check if the requested time slot is available (can be adjusted as needed)
    // You could add additional logic to check for conflicts with existing bookings
   

    // Create a new booking
    const newBooking = new Booking({
      lineId,
      lineName,
      customerUsername,
      userPhone,
      userImage,
      userFirstName,
      userLastName,
      ownerUsername,
      quantity,
      date,
      startTime,
      endTime,
      totalPrice,
      revenuePrice,
      cropType
    });

    // Save the booking to the database
    const savedBooking = await newBooking.save();

    // Respond with the saved booking
    res.status(201).json({
        status: true,
      message: 'Booking created successfully.',
      booking: savedBooking,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ status:false,
        message: 'Server error. Please try again later.' });
  }
};


exports.getBookedTimes = async (req, res) => {
    const { lineId } = req.body; // Extract lineId from request body
    const { date } = req.body;  // Extract date from request body
  
    try {
      // Ensure both lineId and date are provided
      if (!lineId || !date) {
        return res.status(400).json({
          status: false,
          message: 'lineId and date are required.',
        });
      }
  
      // Parse the date to get the start and end of the day
      const startOfDay = new Date(date);
      startOfDay.setHours(0, 0, 0, 0); // Start of the day
      const endOfDay = new Date(date);
      endOfDay.setHours(23, 59, 59, 999); // End of the day
  
      // Query bookings for the given lineId and date
      const bookings = await Booking.find({
        lineId,
        startTime: {
          $gte: startOfDay,
          $lte: endOfDay,
        },
      });
  
      // Format the booked times as "HH:mm - HH:mm"
      const bookedTimes = bookings.map((booking) => {
        const start = new Date(booking.startTime).toLocaleTimeString('en-US', {
          hour: '2-digit',
          minute: '2-digit',
          hour12: false,
        });
        const end = new Date(booking.endTime).toLocaleTimeString('en-US', {
          hour: '2-digit',
          minute: '2-digit',
          hour12: false,
        });
        return `${start}-${end}`;
      });
  
      // Send the response
      res.status(200).json({
        status: true,
        bookedTimes,
      });
    } catch (err) {
      console.error('Error fetching booked times:', err);
      res.status(500).json({
        status: false,
        message: 'Failed to fetch booked times.',
      });
    }
  };
  exports.getOwnerBooking = async (req, res) => {
    const { ownerUsername } = req.params; // Retrieve username from the request body
    console.log("Received username:", ownerUsername);
  
    if (!ownerUsername) {
      return res.status(400).json({ status: false, message: "Username is required" });
    }
  
    try {
      const bookings = await Booking.find({ ownerUsername,
        
       });
      if (!bookings || bookings.length === 0) {
        return res.status(404).json({ message: "No requests found for this owner." });
      }
      res.status(200).json({
        status: true,
        message: 'bookings retrieved successfully',
        bookings,
      });
    } catch (error) {
      res.status(500).json({
        status: false,
        message: 'Error fetching bookings',
        error,
      });
    }
  };
  exports.getCustomerBooking = async (req, res) => {
    const { customerUsername } = req.params; // Retrieve username from the request body
    console.log("Received username:", customerUsername);
  
    if (!customerUsername) {
      return res.status(400).json({ status: false, message: "Username is required" });
    }
  
    try {
      const bookings = await Booking.find({ customerUsername:customerUsername
        
       });
      if (!bookings || bookings.length === 0) {
        return res.status(404).json({ message: "No bookings found for this worker." });
      }
      res.status(200).json({
        status: true,
        message: 'bookings retrieved successfully',
        bookings,
      });
    } catch (error) {
      res.status(500).json({
        status: false,
        message: 'Error fetching requests',
        error,
      });
    }
  }; 
  exports.deleteBooking = async (req, res) => {
    const { id } = req.params;
    console.log("d1");
    try {
      await Booking.findByIdAndDelete(id);
      res.status(200).json({ status:true,message: 'request removed ' });
    console.log("deleted");
    } catch (error) {
        console.log(error);
      res.status(500).json({ status:false, message: 'Error removing request ', error });
    }
  };
  exports.updatebookingStatus = async (req, res) => {
    const { bookingId, status } = req.body; // Retrieve request ID and status from the request body
    //const currentDate = moment().format('YYYY-MM-DD HH:mm:ss'); // Get the current date and time in a specific format

    if (!bookingId || !status) {
        return res.status(400).json({ status: false, message: "Request ID and status are required" });
    }

    try {
        // Find the work request by ID
        const booking = await Booking.findById(bookingId);
        if (!booking) {
            return res.status(404).json({ status: false, message: "Work request not found" });
        }

        // Determine the new status and apply the relevant changes
        if (status === 'Done') {
            // Update request status to accepted
            booking.status = 'confirmed';
            // Decrease the number of workers by 1 (if it's greater than 0)
            
            // Set the owner decision date to the current date
            // workRequest.ownerDecisionDate = Date.now;
        } else if (status === 'Cancelled') {
            // Update request status to rejected
            booking.status = 'canceled';
            // Set the owner decision date to the current date
            // workRequest.ownerDecisionDate = Date.now;
        } else if (status === 'Not Yet') {
          // Update request status to rejected
          booking.status = 'pending';
          // Set the owner decision date to the current date
          // workRequest.ownerDecisionDate = Date.now;
      }
        else {
            return res.status(400).json({ status: false, message: "Invalid status, should be 'accepted' or 'rejected'" });
        }

        // Save the updated work request
        await booking.save();

        res.status(200).json({
            status: true,
            message: `Request ${status} successfully`,
            booking,
        });
    } catch (error) {
        res.status(500).json({
            status: false,
            message: 'Error updating work request status',
            error,
        });
    }
};

