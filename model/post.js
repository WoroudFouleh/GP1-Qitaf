const mongoose = require('mongoose');
const db = require('../config/db');

const postSchema = new mongoose.Schema({
    username: {type: String, required: true }, // Reference to User
    firstName: {type: String, required: true },
    lastName: {type: String, required: true },
    writerImage: {type: String, required: true },
    text: { type: String, required: true },
    image: { type: String, default: null }, // URL or base64 image
    reactions: {
      like: { type: Number, default: 0 },
      love: { type: Number, default: 0 },
      interested: { type: Number, default: 0 },
    },
    comments: [
      {
        user: { type: String, required: true },
        userFirstName: { type: String, required: true },
        userLastName: { type: String, required: true },
        userImage: { type: String, required: true },
        text: { type: String, required: true },
        commentImage: { type: String,default: null },
       commentlikes: { type: Number, default: 0 },
        likePressed:{type: Boolean,default:false},
       createdAt: { type: Date, default: Date.now },
      
    },
    ],
    createdAt: { type: Date, default: Date.now },
  });
  
  const Post = db.model('Post', postSchema);
  module.exports = Post;
  