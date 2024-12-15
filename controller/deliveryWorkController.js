const DeliveryRequest = require('../model/deliveryWorkRequest');
const path = require('path');
const Tesseract = require('tesseract.js');
const moment = require('moment');
const fs = require('fs');
const crypto = require('crypto');
const sendEmail = require('../Utils/email');
const processLicense = async (filePath) => {
  try {
    // Step 1: Perform OCR on the license image with additional options
    const { data: { text } } = await Tesseract.recognize(filePath, 'eng', {
      tessedit_char_whitelist: '0123456789/-',  // Restrict Tesseract to only look for numbers and date separators
      preserve_interword_spaces: '1',  // Preserve spaces between words for better formatting
      logger: (m) => console.log(m),  // Log the OCR process
    });
    console.log('OCR Extracted Text:', text);

    // Step 2: Use regex to find date patterns
    const dateRegex = /(\d{1,2}[\/-]\d{1,2}[\/-]\d{4})/g;
    const dates = text.match(dateRegex);

    if (!dates || dates.length === 0) {
      throw new Error('No valid date found on the license.');
    }

    console.log('Detected Dates:', dates);

    // Step 3: Identify the expiration date
    let expirationDate;
    for (let date of dates) {
      const parsedDate = moment(date, ['DD/MM/YYYY', 'MM-DD-YYYY', 'YYYY-MM-DD'], true);
      if (parsedDate.isValid() && parsedDate.isAfter(moment())) {
        // Assume the latest valid future date is the expiration date
        expirationDate = parsedDate;
        break;
      }
    }

    if (!expirationDate) {
      throw new Error('No valid expiration date found.');
    }

    console.log('Extracted Expiration Date:', expirationDate.format('YYYY-MM-DD'));

    return { isValid: true, expirationDate: expirationDate.format('YYYY-MM-DD') };
  } catch (error) {
    console.error('Error processing license:', error.message);
    return { isValid: false, message: error.message };
  }
};

exports.createDeliveryRequest = async (req, res) => {
  try {
    const { firstName, lastName, email, phoneNumber, city, idNumber, birthDate } = req.body;

    if (!req.file) {
      return res.status(400).json({ message: 'License file is required.' });
    }

    const licenseFilePath = req.file.path;

    // Process the uploaded license to validate expiration date
    const licenseValidation = await processLicense(licenseFilePath);

    if (!licenseValidation.isValid) {
      // Delete the uploaded file if the license is invalid
      fs.unlinkSync(licenseFilePath);
      return res.status(400).json({ message: licenseValidation.message });
    }

    // Step 2: Save the delivery request if the license is valid
    const deliveryRequest = new DeliveryRequest({
      firstName,
      lastName,
      email,
      phoneNumber,
      city,
      idNumber,
      birthDate: JSON.parse(birthDate), // Expecting a JSON string for birthDate
      licenseFile: licenseFilePath,
      //licenseExpirationDate: licenseValidation.expirationDate, // Store expiration date if needed
    });

    await deliveryRequest.save();
    res.status(201).json({ message: 'Delivery request created successfully!' });
  } catch (error) {
    console.error('Error creating delivery request:', error.message);
    res.status(500).json({ message: 'An error occurred while processing the request.' });
  }
};
exports.getAllRequests = async (req, res) => {
  try {
      const requests = await DeliveryRequest.find({ status: 'pending' }); // Retrieve all advertisements
      res.status(200).json({ status: true, requests });
  } catch (error) {
      res.status(500).json({ status: false, message: 'Error fetching requests', error });
  }
};
exports.updateRequestStatus = async (req, res) => {
  try {
    const { requestId, status } = req.body; // Expecting requestId and status in the body

    if (!requestId || !status) {
      return res.status(400).json({ message: 'Both requestId and status are required.' });
    }

    // Validate the status (optional, you can add any valid statuses)
    const validStatuses = ['pending', 'approved', 'rejected', 'completed'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ message: 'Invalid status.' });
    }

    // Find the request by requestId
    const deliveryRequest = await DeliveryRequest.findById(requestId);

    if (!deliveryRequest) {
      return res.status(404).json({ message: 'Request not found.' });
    }

    // Update the status
    deliveryRequest.status = status;
    
    // Save the updated request
    await deliveryRequest.save();

    res.status(200).json({ message: 'Request status updated successfully!', status: deliveryRequest.status });
  } catch (error) {
    console.error('Error updating request status:', error.message);
    res.status(500).json({ message: 'An error occurred while updating the status.' });
  }
};
// Utility function to generate a random password
function generatePassword() {
  return crypto.randomBytes(4).toString('hex'); // Generates a 16-character password
}

// Utility function to create a username (example: first name + ID)
function generateUsername(firstName, lastName, userId) {
  const firstNamePart = firstName.slice(0, 2).toLowerCase(); // Take the first 2 letters of the first name
  const lastNamePart = lastName.slice(0, 2).toLowerCase();
  const idPart = userId.slice(0, 2).toLowerCase(); // Take the first 2 letters of the last name
  return `${firstNamePart}.${lastNamePart}${idPart}`;
}

exports.generateCredentials = async (req, res) => {
  try {
    const { firstName, lastName, userId } = req.body;

    if (!firstName || !lastName || !userId) {
      return res.status(400).json({ message: 'Missing required fields' });
    }
  
    const username = generateUsername(firstName, lastName, userId);
    const password = generatePassword();
  

    return res.status(200).json({ username, password });
  } catch (error) {
    console.error('Error updating request status:', error.message);
    res.status(500).json({ message: 'An error occurred while updating the status.' });
  }
};
exports.sendInfoByEmail = async (req, res, next) => {
  const { username, password, email } = req.body;
  
 

  // 4: Send email with the 4-digit code
  const message = `Congrats! \n Your request to work as a delivery on QItaf app is approved. Your username is ${username} and your password is ${password}. \n make sure to use them when logging in to the app.`;
  
  try {
      await sendEmail({
          email: email,
          subject: 'Password Reset Code',
          message: message
      });

      res.status(200).json({
          status: true,
          message: 'email sent successfully'
      });
  } catch (err) {
      

      return res.status(500).json({ status: 'fail', message: 'Error sending email' });
  }
};

// const DeliveryRequest = require('../model/deliveryWorkRequest');
// const path = require('path');
// const Tesseract = require('tesseract.js');
// const moment = require('moment');
// const fs = require('fs');
// const twilio = require('twilio'); // Twilio for SMS

// // Twilio configuration
// const TWILIO_ACCOUNT_SID = 'ACa2f8744ecf2c10777af3c408445592e7'; // Replace with your Twilio Account SID
// const TWILIO_AUTH_TOKEN = 'e41b1320783ae59385f5dba1774dc7cb'; // Replace with your Twilio Auth Token
// const TWILIO_PHONE_NUMBER = '+12249703026'; // Replace with your Twilio phone number
// const twilioClient = twilio(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN);

// const sendRejectionSMS = async (phoneNumber, message) => {
//   try {
//     await twilioClient.messages.create({
//       to: phoneNumber,
//       from: TWILIO_PHONE_NUMBER,
//       body: message,
//     });
//     console.log(`Rejection SMS sent to ${phoneNumber}`);
//   } catch (error) {
//     console.error('Failed to send SMS:', error.message);
//   }
// };

// const processLicense = async (filePath) => {
//   try {
//     // Step 1: Perform OCR on the license image with additional options
//     const { data: { text } } = await Tesseract.recognize(filePath, 'eng', {
//       tessedit_char_whitelist: '0123456789/-', // Restrict Tesseract to only look for numbers and date separators
//       preserve_interword_spaces: '1', // Preserve spaces between words for better formatting
//       logger: (m) => console.log(m), // Log the OCR process
//     });
//     console.log('OCR Extracted Text:', text);

//     // Step 2: Use regex to find date patterns
//     const dateRegex = /(\d{1,2}[\/-]\d{1,2}[\/-]\d{4})/g;
//     const dates = text.match(dateRegex);

//     if (!dates || dates.length === 0) {
//       throw new Error('No valid date found on the license.');
//     }

//     console.log('Detected Dates:', dates);

//     // Step 3: Identify the expiration date
//     let expirationDate;
//     for (let date of dates) {
//       const parsedDate = moment(date, ['DD/MM/YYYY', 'MM-DD-YYYY', 'YYYY-MM-DD'], true);
//       if (parsedDate.isValid() && parsedDate.isAfter(moment())) {
//         // Assume the latest valid future date is the expiration date
//         expirationDate = parsedDate;
//         break;
//       }
//     }

//     if (!expirationDate) {
//       throw new Error('No valid expiration date found.');
//     }

//     console.log('Extracted Expiration Date:', expirationDate.format('YYYY-MM-DD'));

//     return { isValid: true, expirationDate: expirationDate.format('YYYY-MM-DD') };
//   } catch (error) {
//     console.error('Error processing license:', error.message);
//     return { isValid: false, message: error.message };
//   }
// };

// exports.createDeliveryRequest = async (req, res) => {
//   try {
//     const { firstName, lastName, email, phoneNumber, city, idNumber, birthDate } = req.body;

//     if (!req.file) {
//       return res.status(400).json({ message: 'License file is required.' });
//     }

//     const licenseFilePath = req.file.path;

//     // Process the uploaded license to validate expiration date
//     const licenseValidation = await processLicense(licenseFilePath);

//     if (!licenseValidation.isValid) {
//       // Send rejection SMS to the user
//       const rejectionMessage = `Dear ${firstName} ${lastName}, your delivery work request in Qitaf App has been rejected. Reason: ${licenseValidation.message}`;
//       await sendRejectionSMS(phoneNumber, rejectionMessage);

//       // Delete the uploaded file if the license is invalid
//       fs.unlinkSync(licenseFilePath);
//       return res.status(400).json({ message: licenseValidation.message });
//     }
// console.log(phoneNumber);
//     // Step 2: Save the delivery request if the license is valid
//     const deliveryRequest = new DeliveryRequest({
//       firstName,
//       lastName,
//       email,
//       phoneNumber,
//       city,
//       idNumber,
//       birthDate: JSON.parse(birthDate), // Expecting a JSON string for birthDate
//       licenseFile: licenseFilePath,
//       licenseExpirationDate: licenseValidation.expirationDate, // Store expiration date if needed
//     });

//     await deliveryRequest.save();
//     res.status(201).json({ message: 'Delivery request created successfully!' });
//   } catch (error) {
//     console.error('Error creating delivery request:', error.message);
//     res.status(500).json({ message: 'An error occurred while processing the request.' });
//   }
// };
