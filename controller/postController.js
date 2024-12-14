const Post = require('../model/post');

exports.createPost = async (req, res) => {
  try {
    const { username,firstName, lastName, writerImage, text, image } = req.body;

    // Validate the required fields
    if (!username || !text || !firstName ||!lastName ) {
      return res.status(400).json({ message: 'Username and text are required' });
    }

    // Create a new post instance
    const newPost = new Post({
      username,
      firstName,
      lastName,
      writerImage: writerImage || null,
      text,
      image: image || null, // Optional field
    });

    // Save the post to the database
    await newPost.save();

    res.status(201).json({
        status: true,
      message: 'Post created successfully',
      post: newPost,
    });
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({status: flase, message: 'Internal server error' });
  }
};
exports.getAllPosts = async (req, res) => {
    try {
      // Fetch all posts from the database
      const posts = await Post.find().sort({ createdAt: -1 }); // Sort posts by creation date (most recent first)
  
      // Iterate over each post and sort its comments by number of likes
      const sortedPosts = posts.map((post) => {
        const sortedComments = [...post.comments].sort((a, b) => b.commentlikes - a.commentlikes);
        return {
          ...post.toObject(), // Convert Mongoose document to plain object
          comments: sortedComments,
        };
      });
  
      res.status(200).json({
        status: true,
        message: 'Posts retrieved successfully',
        posts: sortedPosts,
      });
    } catch (error) {
      console.error('Error fetching posts:', error);
      res.status(500).json({
        status: false,
        message: 'Internal server error',
      });
    }
  };
  
 exports.addComment = async (req, res) => {
    const { postId, text, username, userFirstName, userLastName, userImage, commentImage } = req.body; // Extract values from the request body
    
    try {
      // Validate that all necessary fields are provided
      if (!postId || !text || !username || !userFirstName || !userLastName || !userImage) {
        return res.status(400).json({ message: 'Post ID, text, username, userFirstName, userLastName, and userImage are required.' });
      }
  
      // Find the post by ID
      const post = await Post.findById(postId);
      
      if (!post) {
        return res.status(404).json({ message: 'Post not found.' });
      }
  
      // Create the new comment object
      const newComment = {
        user: username,
        userFirstName: userFirstName,
        userLastName: userLastName,
        userImage: userImage,
        text: text,
        createdAt: new Date(), // Automatically set the creation date
        commentImage: commentImage || null, // Optional comment image, defaults to null
      };
  
      // Add the new comment to the comments array
      post.comments.push(newComment);
  
      // Save the post with the new comment
      await post.save();
  
      // Respond with the updated post or just a success message
      return res.status(201).json({ message: 'Comment added successfully!', post });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: 'Server error.' });
    }
  };

  exports.addReaction = async (req, res) => {
    try {
      const { postId, reactionType, operation } = req.body;
  
      // Validate reaction type
      const validReactions = ['like', 'love', 'interested'];
      if (!validReactions.includes(reactionType)) {
        return res.status(400).json({ status: false, message: 'Invalid reaction type' });
      }
  
      // Validate operation
      const validOperations = ['add', 'remove'];
      if (!validOperations.includes(operation)) {
        return res.status(400).json({ status: false, message: 'Invalid operation' });
      }
  
      // Determine the increment or decrement value based on the operation
      const incrementValue = operation === 'add' ? 1 : -1;
  
      // Update the reaction count
      const updatedPost = await Post.findByIdAndUpdate(
        postId,
        { $inc: { [`reactions.${reactionType}`]: incrementValue } },
        { new: true } // Return the updated document
      );
  
      if (!updatedPost) {
        return res.status(404).json({ status: false, message: 'Post not found' });
      }
  
      res.status(200).json({
        status: true,
        message: `Reaction "${reactionType}" ${operation === 'add' ? 'added' : 'removed'} successfully`,
        post: updatedPost,
      });
    } catch (error) {
      console.error('Error managing reaction:', error);
      res.status(500).json({ status: false, message: 'Server error', error });
    }
  };
  
// Function to like a comment

// Function to handle like operations on a comment
exports.updateCommentLikes = async (req, res) => {
  try {

    const { postId, commentId,operation } = req.body; // `add` or `remove`

    // Validate operation
    if (!['add', 'remove'].includes(operation)) {
      return res.status(400).json({ message: "Invalid operation. Use 'add' or 'remove'." });
    }

    // Determine the increment value based on the operation
    const incrementValue = operation === 'add' ? 1 : -1;

    // Find the post and update the comment's likes
    const post = await Post.findOneAndUpdate(
      { _id: postId, "comments._id": commentId },
      { $inc: { "comments.$.commentlikes": incrementValue } }, // Increment or decrement
      { new: true } // Return the updated document
    );

    if (!post) {
      return res.status(404).json({status:false,  message: "Post or comment not found" });
    }

    res.status(201).json({
        status:true,
      message: `Comment ${operation === 'add' ? 'liked' : 'unliked'} successfully`,
      post,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({status:false, message: "Internal Server Error" });
  }
};
// Delete a post
exports.deletePost = async (req, res) => {
    const { postId } = req.params;  // Get postId from URL parameters
  
    try {
      const post = await Post.findById(postId);
      
      if (!post) {
        return res.status(404).json({ status: false, message: 'Post not found' });
      }
  
      // Delete the post
      await Post.findByIdAndDelete(postId);
      res.status(200).json({
        status: true,
        message: 'Post deleted successfully',
      });
    } catch (error) {
      console.error('Error deleting post:', error);
      res.status(500).json({
        status: false,
        message: 'Internal server error',
      });
    }
  };
  // Edit a post
exports.editPost = async (req, res) => {
    const { postId } = req.params;  // Get postId from URL parameters
    const { text } = req.body;  // Get the text and image from the request body
  
    try {
      const post = await Post.findById(postId);
      
      if (!post) {
        return res.status(404).json({ status: false, message: 'Post not found' });
      }
  
      // Update the post fields
      post.text = text || post.text; // Update only if new text is provided
       // Update only if new image is provided
  
      await post.save();
      res.status(200).json({
        status: true,
        message: 'Post updated successfully',
        post: post,
      });
    } catch (error) {
      console.error('Error updating post:', error);
      res.status(500).json({
        status: false,
        message: 'Internal server error',
      });
    }
  };
  // Delete a comment from a post
exports.deleteComment = async (req, res) => {
    const { postId, commentId } = req.params;  // Get postId and commentId from URL parameters
  
    try {
      const post = await Post.findById(postId);
      
      if (!post) {
        return res.status(404).json({ status: false, message: 'Post not found' });
      }
  
      const commentIndex = post.comments.findIndex(comment => comment._id.toString() === commentId);
  
      if (commentIndex === -1) {
        return res.status(404).json({ status: false, message: 'Comment not found' });
      }
  
      // Remove the comment
      post.comments.splice(commentIndex, 1);  // Remove the comment at the specified index
      await post.save();
  
      res.status(200).json({
        status: true,
        message: 'Comment deleted successfully',
      });
    } catch (error) {
      console.error('Error deleting comment:', error);
      res.status(500).json({
        status: false,
        message: 'Internal server error',
      });
    }
  };
  // Edit a comment
exports.editComment = async (req, res) => {
    const { postId, commentId } = req.params;  // Get postId and commentId from URL parameters
    const { text } = req.body;  // Get the new text and commentImage from the request body
  
    try {
      const post = await Post.findById(postId);
      
      if (!post) {
        return res.status(404).json({ status: false, message: 'Post not found' });
      }
  
      const comment = post.comments.find(comment => comment._id.toString() === commentId);
  
      if (!comment) {
        return res.status(404).json({ status: false, message: 'Comment not found' });
      }
  
      // Update the comment fields
      comment.text = text || comment.text;
      
  
      await post.save();
  
      res.status(200).json({
        status: true,
        message: 'Comment updated successfully',
        comment: comment,
      });
    } catch (error) {
      console.error('Error updating comment:', error);
      res.status(500).json({
        status: false,
        message: 'Internal server error',
      });
    }
  };
  

