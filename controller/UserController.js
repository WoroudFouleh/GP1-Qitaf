const UserServices = require('../services/UserService');
const User=require('../model/user');
const DeliveryMan=require('../model/deliveryMan');
//const Util=require('util');
const sendEmail = require('../Utils/email');
const { stat } = require('fs');
const crypto = require('crypto');
const bcrypt = require('bcrypt');
const jwt = require ('jsonwebtoken');

exports.register = async (req, res, next) => {
    try {
        console.log("---req body---", req.body);
        
        // Destructure the required fields from the request body
        const {
            firstName,
                lastName,
                email,
                phoneCode,
                phoneNumber,
                password,
                city,
                street,
                dayOfBirth,
                monthOfBirth,
                yearOfBirth,
                gender,
                profilePhoto,
                username,
                userType
        } = req.body;

        // // Check for duplicate email
        // const duplicate = await UserServices.getUserByEmail(email);
        // if (duplicate) {
        //     throw new Error(`User with email ${email} is already registered`);
        // }

        // Register the user by passing all the necessary fields
        const response = await UserServices.registerUser({
            firstName,
                lastName,
                email,
                phoneCode,
                phoneNumber,
                password,
                city,
                street,
                dayOfBirth,
                monthOfBirth,
                yearOfBirth,
                gender,
                profilePhoto,
                username,
                userType
        });

        // Send a success response
        res.json({ status: true, success: 'User registered successfully' });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);  // Pass the error to the next middleware (error handler)
    }
}
//module.exports=UserController;
exports.login = async (req, res, next) => {
    try {
        console.log("Request Body from Flutter:", req.body);

        const { email, password } = req.body;

        // Check if user exists with the provided email
        const user = await UserServices.checkUser(email);
        const deliveryMan = await DeliveryMan.findOne({ email: email });

        console.log("User:", user);
        console.log("DeliveryMan:", deliveryMan);

        if (!user) {
            // Send 401 Unauthorized if the user doesn't exist in the User table
            return res.status(401).json({ status: false, message: 'User does not exist' });
        }

        // Verify password only for User
        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            return res.status(401).json({ status: false, message: 'Invalid password' });
        }

        // Generate user token
        const userTokenData = {
            _id: user._id,
            username: user.username,
            email: user.email,
            dayOfBirth: user.dayOfBirth,
            monthOfBirth: user.monthOfBirth,
            yearOfBirth: user.yearOfBirth,
            phoneCode: user.phoneCode,
            phoneNumber: user.phoneNumber,
            street: user.street,
            city: user.city,
            profilePhoto: user.profilePhoto,
            userType: user.userType,
            firstName: user.firstName,
            lastName: user.lastName,
            gender: user.gender,
            password: user.password,
            rate: user.rate
        };
        const userToken = await UserServices.generateToken(userTokenData, "secretKey", '1h');

        // If email exists in both User and DeliveryMan tables
        if (deliveryMan) {
            console.log("Email found in both User and DeliveryMan tables");

            // Generate deliveryMan token
            const deliveryTokenData = {
                _id: deliveryMan._id,
                email: deliveryMan.email,
                userType: 'delivery',
                firstName: deliveryMan.firstName,
                lastName: deliveryMan.lastName,
                phoneNumber: deliveryMan.phoneNumber
            };
            const deliveryToken = await UserServices.generateToken(deliveryTokenData, "secretKey", '1h');

            return res.status(200).json({
                status: true,
                success: 'Email exists in both User and DeliveryMan tables',
                userType: "3", // Type 3 indicates email found in both tables
                token: userToken,
                deliveryToken: deliveryToken
            });
        }

        // If email exists only in User table
        return res.status(200).json({
            status: true,
            success: "Login successful",
            userType: user.userType,
            token: userToken
        });

    } catch (err) {
        console.log("---> err -->", err);
        next(err); // Pass the error to the next middleware (error handler)
    }
};




// Forgot Password
exports.forgotPassword = async (req, res, next) => {
    console.log("Forgot Password Request Body:", req.body);
    
    // 1: Find the user by email
    const email=req.body.email;
    const user = await User.findOne({ username: req.body.username });
    if (!user) {
        return res.status(404).json({ status: 'fail', message: 'User not found with this email' });
    }

    // 2: Generate a 4-digit reset code
    const resetCode = Math.floor(1000 + Math.random() * 9000).toString(); // Changed from 6 to 4 digits

    // 3: Hash the reset code and store it in the user's document along with expiration
    user.passwordResetToken = crypto.createHash('sha256').update(resetCode).digest('hex');
    user.passwordResetTokenExpires = Date.now() + 10 * 60 * 1000; // Expires in 10 minutes
    await user.save({ validateBeforeSave: false });

    // 4: Send email with the 4-digit code
    const message = `We received a request to reset your password. Your password reset code is: ${resetCode}. This code is valid for 10 minutes.`;
    
    try {
        await sendEmail({
            email: email,
            subject: 'Password Reset Code',
            message: message
        });

        res.status(200).json({
            status: true,
            message: 'Password reset code sent to the email'
        });
    } catch (err) {
        user.passwordResetToken = undefined;
        user.passwordResetTokenExpires = undefined;
        await user.save({ validateBeforeSave: false });

        return res.status(500).json({ status: 'fail', message: 'Error sending email' });
    }
};



exports.verifyCode = async (req, res, next) => {
    try {
        const { username, code } = req.body;

        // Hash the received code
        
        const hashedCode = crypto.createHash('sha256').update(code).digest('hex');
        console.log("Hashed token (code):", hashedCode);  // Debugging log

        // Find user by email and matching token that hasn't expired
        const user = await User.findOne({ 
            username: username, 
            passwordResetToken: hashedCode, 
            passwordResetTokenExpires: { $gt: Date.now() } 
        });

        if (!user) {
            console.log("No user found with this code or the code has expired.");
            return res.status(400).json({ status: false, message: "Invalid or expired code" });
        }

        // If the code is correct
        res.status(200).json({ status: true, message: "Code verified, proceed to reset password" });
    } catch (error) {
        console.error("Error during code verification:", error);
        return res.status(500).json({ status: false, message: "Server error" });
    }
};

// Function to reset the password
exports.updatePassword = async (req, res, next) => {
    try {
        const { password } = req.body; // Get the password from the request body
        const username = req.params.username; // Get the email from the URL parameters

        // Find the user by email
        const user = await User.findOne({ username: username });

        if (!user) {
            console.log("No user found with this email.");
            return res.status(404).json({ message: "User not found" }); // Use 404 for not found
        }

        // Hash the new password before saving
        // const salt = await bcrypt.genSalt(10);
        // const hashedPassword = await bcrypt.hash(password, salt);
        console.log("Hashed Password:", password);
        user.password = password; // Update the user's password with the hashed version
        user.passwordResetToken = undefined; // Clear reset token fields if needed
        user.passwordResetTokenExpires = undefined;

        // Save the user with the new password
        await user.save();
        console.log("New Hashed Password after reset:", user.password);
        //res.status(200).json({ message: "Password updated successfully" });
        let tokenData = { _id: user._id, username: user.username , email:user.email,dayOfBirth:user.dayOfBirth, monthOfBirth:user.monthOfBirth , yearOfBirth:user.yearOfBirth,
            phoneCode:user.phoneCode, phoneNumber:user.phoneNumber, street:user.street, city: user.city, profilePhoto:user.profilePhoto, userType: user.userType,
            firstName: user.firstName, lastName: user.lastName, gender: user.gender, password: user.password
         };
        const token = await UserServices.generateToken(tokenData, "secretKey", '1h');

        // Send the token and success response
        res.status(200).json({
            status: true,
            success: "Password updated successfully",
            token: token,
            userType: user.userType
        });

    } catch (error) {
        console.error("Error during password update:", error);
        return res.status(500).json({ message: "Server error" });
    }
};

exports.updateUser = async (req, res, next) => {
    try {
        const username = req.params.username; // Get the username from the URL params

        // Find the user by username
        const user = await User.findOne({ username: username });

        if (!user) {
            console.log("No user found with this username.");
            return res.status(404).json({ message: "User not found" }); // Use 404 for not found
        }

        // Destructure the fields from the request body
        const {
            firstName,
            lastName,
            email,
            phoneCode,
            phoneNumber,
            city,
            street,
            profilePhoto,
        } = req.body;

        // Update only the fields that are provided
        if (firstName) user.firstName = firstName;
        if (lastName) user.lastName = lastName;
        if (email) user.email = email;
        if (phoneCode) user.phoneCode = phoneCode;
        if (phoneNumber) user.phoneNumber = phoneNumber;
        if (city) user.city = city;
        if (street) user.street = street;
        if (profilePhoto) user.profilePhoto = profilePhoto;


        // Hash the password if provided
        // if (password) {
        //     const salt = await bcrypt.genSalt(10);
        //     const hashedPassword = await bcrypt.hash(password, salt);
        //     user.password = hashedPassword;
        // }

        // Save the updated user information
        await user.save();
        console.log("User updated successfully:", user);

        let tokenData = {
            username: user.username,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            phoneCode: user.phoneCode,
            phoneNumber: user.phoneNumber,
            city: user.city,
            street: user.street,
            profilePhoto: user.profilePhoto,
            password: user.password
        };
        const token = await UserServices.generateToken(tokenData, "secretKey", '1h');


        res.status(200).json({ message: "User updated successfully", user , token:token});
    } catch (error) {
        console.error("Error during user update:", error);
        return res.status(500).json({ message: "Server error" });
    }
};



exports.verifyPassword = async (req, res, next) => {
    try {
        const { enteredPassword, hashedPassword } = req.body;

        // Compare the entered password with the stored hashed password
        const isMatch = await bcrypt.compare(enteredPassword, hashedPassword);

        // Log the comparison result
        console.log("Entered Password:", enteredPassword);
        console.log("Stored Hashed Password:", hashedPassword);
        console.log(isMatch);

        if (isMatch) {
            return res.json({
                status: true,
                message: 'Password matched successfully',
            });
        } else {
            return res.json({
                status: false,
                message: 'Invalid password',
            });
        }
    } catch (error) {
        console.error('Error comparing passwords:', error);
        return res.status(500).json({
            status: false,
            message: 'Error comparing passwords',
        });
    }
};

exports.getUserInfo = async (req, res) => {
    try {
      const { username } = req.params;
      console.log("heree"); // Extract the username from the URL
      if (!username) {
        return res.status(400).json({
          status: false,
          message: 'Username is required',
        });
      }
  
      // Find the user by username
      const user = await User.findOne({ username });
  
      if (!user) {
        return res.status(404).json({
          status: false,
          message: 'User not found',
        });
      }
  
      // Respond with the user's information
      return res.status(200).json({
        status: true,
        data: {
          firstName: user.firstName,
          lastName: user.lastName,
          profilePhoto: user.profilePhoto,
          phoneNumber: user.phoneNumber,
          email: user.email,
          phoneCode: user.phoneCode,
          city: user.city,
          street: user.street,
          postNumber:user.postsCount,
          gender:user.gender
        },
      });
    } catch (error) {
      console.error('Error fetching user info:', error);
      return res.status(500).json({
        status: false,
        message: 'An error occurred while fetching user info',
      });
    }
  };
  
  exports.updateUserPosts = async (req, res, next) => {
    try {
        const { username } = req.params;
        console.log("Received username:", username);

        // Validate the productId format
        

        // Validate the new rate (it should be between 1 and 5)
        
        // Find the product
        const user = await User.findOne({ username });
  
      if (!user) {
        return res.status(404).json({
          status: false,
          message: 'User not found',
        });
      }

        // Calculate new average rate
        //const totalRating = product.rate + newRateInt;
        user.postsCount += 1; // Increment count
        //product.rate = totalRating / 2; // Update average rate

        // Save the updated product
        await user.save();

        res.status(200).json({
            status: true,
            success: "posts number updated successfully",
            
        });
    } catch (err) {
        console.error("---> Error in updating rate --->", err);
        next(err);
    }
};
const mongoose = require('mongoose');
  exports.rateWorker = async (req, res, next) => {
    try {
        const { username, newRate } = req.body;
        console.log("Received username:", username);

        // Validate the productId format
        

        // Validate the new rate (it should be between 1 and 5)
        if (newRate < 1 || newRate > 5) {
            return res.status(400).json({ status: false, error: "Rate must be between 1 and 5" });
        }

        // Convert newRate to an integer
        const newRateInt = Math.round(newRate);

        // Convert productId to ObjectId
        //const objectId = new mongoose.Types.ObjectId(productionLineId);

        // Find the product
        const user = await User.findOne({username});

        if (!user) {
            return res.status(404).json({ status: false, error: "user not found" });
        }

        // Calculate new average rate
        const totalRating = user.rate + newRateInt;
        ///user.rateCount += 1; // Increment count
        user.rate = totalRating / 2; // Update average rate

        // Save the updated product
        await user.save();

        res.status(200).json({
            status: true,
            success: "user rating updated successfully",
            
        });
    } catch (err) {
        console.error("---> Error in updating rate --->", err);
        next(err);
    }
};

exports.getUserStatistics = async (req, res) => {
    try {
      const totalUsers = await User.countDocuments();
      const stats = await User.aggregate([
        { $group: { _id: "$city", count: { $sum: 1 } } },
        { $project: { city: "$_id", count: 1, percentage: { $multiply: [{ $divide: ["$count", totalUsers] }, 100] } } },
      ]);
      res.json(stats);
    } catch (error) {
      res.status(500).json({ message: "Server error", error });
    }
  };
  
  