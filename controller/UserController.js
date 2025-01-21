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
            rate: user.rate,
            points: user.points,
            postsCount: user.postsCount
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
                phoneNumber: deliveryMan.phoneNumber,
                city:deliveryMan.location,
                status:deliveryMan.status,
                coordinates: deliveryMan.coordinates
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
  async function getUserPoints(username) {
    // Replace with your actual database query
    const user = await User.findOne({ username: username });
    if (user) {
      return user.points;
    } else {
      throw new Error('User not found');
    }
  }
  
  // Discount calculation function based on points
  function calculateDiscount(points) {
    if (points >= 100) {
      return 30;  // 30% discount for 100 points or more
    } else if (points >= 50) {
      return 20;  // 20% discount for 50 points or more
    } else if (points >= 20) {
      return 10;  // 10% discount for 20 points or more
    } else if (points >= 10) {
      return 5;   // 5% discount for 10 points or more
    } else {
      return 0;   // No discount for less than 10 points
    }
  }
  
  exports.calculateDiscount = async (req, res) => {
    const { username } = req.body; // Get username from the request body
  
    try {
      // Get user points from the database
      const points = await getUserPoints(username);
  
      // Calculate the discount based on points
      const discountPercentage = calculateDiscount(points);
  
      // Reset the user's points to 0
      await User.updateOne({ username: username }, { $set: { points: 0 } });
  console.log("in discount");
      // Send back the discount percentage
      res.json({ status: true, discountPercentage });
    } catch (error) {
      res.status(500).json({ error: 'Failed to calculate discount', message: error.message });
    }
  };
  // Increment reports for a user
exports.incrementUserReports = async (req, res) => {
    try {
      const { username } = req.body; // Extract the username from the request body
  
      if (!username) {
        return res.status(400).json({ message: 'Username is required.' });
      }
  
      // Find the user by username and increment the reports field
      const user = await User.findOneAndUpdate(
        { username },
        { $inc: { reports: 1 } }, // Increment reports by 1
        { new: true } // Return the updated user document
      );
  
      if (!user) {
        return res.status(404).json({ message: 'User not found.' });
      }
  
      res.status(200).json({
        success: true,
        message: 'User reports incremented successfully.',
        updatedReports: user.reports,
      });
    } catch (error) {
      console.error('Error incrementing user reports:', error);
      res.status(500).json({ message: 'Internal server error.', error });
    }
  };
  exports.checkUserSuspension = async (req, res) => {
    console.log("in sus");
    
    const { email } = req.body; // Extract the email from the request body
  
    if (!email) {
        console.log("in sus2");
        return res.status(400).json({ message: 'Email is required.' });
    }

    try {
        const user = await User.findOne({ email: email });

        if (!user) {
            console.log("in sus3");
            return res.status(404).json({ message: 'User not found.' });
        }

        const suspensionPeriod = 3 * 24 * 60 * 60 * 1000; // 3 days in milliseconds

        if (user.isSuspended) {//true
            console.log("in sus3");
            // Check if suspension period has ended
            const suspensionEndDate = new Date(user.suspensionStartDate.getTime() + suspensionPeriod);
            const now = new Date();
            console.log(now);
            console.log(suspensionEndDate);
            if (now >= suspensionEndDate) {//not suspend
                console.log("in sus4");
                // Reset suspension and reports
                user.isSuspended = false;
                user.reports = 0;
                user.suspensionStartDate = null;
                await user.save();

                return res.status(200).json({
                    suspended: false,
                    message: 'Suspension period ended. User is no longer suspended.',
                });
            } else {//susbended
                console.log("in sus5");
                return res.status(200).json({
                    suspended: true,
                    remainingTime: suspensionEndDate - now,
                    message: 'User is currently suspended.',
                });
            }
        } else if (user.reports >= 3) {
            // Suspend the user
            console.log("suspended");
            user.isSuspended = true;
            user.suspensionStartDate = new Date();
            await user.save();

            return res.status(200).json({
                suspended: true,
                remainingTime: suspensionPeriod,
                message: 'User has been suspended due to excessive reports.',
            });
        }

        console.log("not suspended");
        return res.status(200).json({
            suspended: false,
            message: 'User is not suspended.',
        });
    } catch (err) {
        console.error("Error in suspension check:", err);
        return res.status(500).json({ message: 'Internal server error.', error: err.message });
    }
};

exports.incrementUserPoints = async (req, res) => {
    try {
        const { username, points } = req.body;
console.log(points);
        // Validate input
        if (!username || points === undefined) {
            return res.status(400).json({ error: "Username and points are required." });
        }

        if (typeof points !== "number" || points < 0) {
            return res.status(400).json({ error: "Points must be a non-negative number." });
        }

        // Find the user by username and increment points
        const user = await User.findOneAndUpdate(
            { username },
            { $inc: { points } },
            { new: true } // Return the updated document
        );

        if (!user) {
            return res.status(404).json({ error: "User not found." });
        }

        return res.status(200).json({
            status: true,
            message: "Points updated successfully.",
            updatedUser: {
                username: user.username,
                points: user.points,
            },
        });
    } catch (error) {
        console.error("Error updating points:", error);
        return res.status(500).json({status:false, error: "An error occurred while updating points." });
    }
};
  