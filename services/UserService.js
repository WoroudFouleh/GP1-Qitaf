const UserModel = require("../model/user");
const jwt = require ('jsonwebtoken');

class UserServices {

    static async registerUser({firstName,lastName,email,phoneCode,phoneNumber,password,city,street,dayOfBirth,monthOfBirth,yearOfBirth,gender,profilePhoto,username,userType}) {
        try {
            console.log("----- Registering User -----");
            console.log({
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

            const createUser = new UserModel({
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

            return await createUser.save();
        } catch (err) {
            throw err;
        }
    }
    static async checkUser(username){
        try {
            return await UserModel.findOne({username});
        } catch (error) {
            throw error;
        }
    }
    static async generateToken(tokenData,secretKey,jwt_expire){
        return jwt.sign(tokenData,secretKey,{expiresIn:jwt_expire});
    }
}


module.exports= UserServices;