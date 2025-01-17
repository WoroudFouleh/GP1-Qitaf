const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const db = require('../config/db');
const crypto = require('crypto');

// Define the user schema
const userSchema = new mongoose.Schema({
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    email: { type: String, required: true, unique: true, lowercase: true },
    phoneCode: { type: String, required: true },  // For country or area code
    phoneNumber: { type: String, required: true },
    password: { type: String, required: true },
    city: { 
        type: String, 
        enum: [
            'القدس',
            'القدس',
    'بيت لحم',
    'طوباس',
    'رام الله',
    'نابلس',
    'الخليل',
    'جنين',
    'طولكرم',
    'قلقيلية',
    'سلفيت',
    'أريحا',
    'غزة',
    'دير البلح',
    'خان يونس',
    'رفح',
    'الداخل الفلسطيني'], // List of allowed cities
        required: true 
    },
    street: { type: String },
    dayOfBirth: { type: String, required: true },
    monthOfBirth: { type: String, required: true },
    yearOfBirth: { type: String, required: true },
    gender: { 
        type: String, 
        enum: ['ذكر', 'أنثى'], 
        required: true 
    },
    profilePhoto: { type: String },  // URL or file path
    username: { type: String, required: true, unique: true },
    userType:{type: String, required:true},
    passwordResetToken: String, // Reset token
    passwordResetTokenExpires: Date,// Token expiry time
    postsCount: { type: Number, default: 0 },
    rate: {
        type: Number,
        default: 5, // Initial value
        min: 0, // Ensures the rate cannot go below 0
        max: 5 // Optional: Add if you want to restrict ratings to a 0-5 scale
    },
    points: {
        type: Number,
        default: 0, // Initial value
    },
    reports: {
        type: Number,
        default: 0, // Initial value
    },

}, {
    timestamps: true // Automatically adds createdAt and updatedAt fields
});

// Hash the password before saving it
userSchema.pre("save", async function(next) {
    const user = this;
    if (!user.isModified("password")) {
        return next();
    }

    try {
        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(user.password, salt);
        user.password = hash;
        next();
    } catch (err) {
        next(err);
    }
});

// Compare input password with the hashed password
userSchema.methods.comparePassword = async function(userPassword) {
    try {

        return await bcrypt.compare(userPassword,this.password);
    } catch (err) {
        throw err;
    }
}

// Create a password reset token
userSchema.methods.createResetPasswordToken = function() {
   const resetToken = crypto.randomBytes(32).toString('hex'); // Plain reset token
   this.passwordResetToken = crypto.createHash('sha256').update(resetToken).digest('hex'); // Hashed token saved in the DB
   this.passwordResetTokenExpires = Date.now() + 10 * 60 * 1000; // Token expires in 10 minutes

   return resetToken; // Return the plain reset token to send to the user
}

// Create and export the model
const UserModel = db.model('User', userSchema);
module.exports = UserModel;
