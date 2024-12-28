const axios = require('axios');
const { json } = require('body-parser');
const { application, response } = require('express');



// Define the Bearer token and API endpoint
const token = 'ya29.c.c0ASRK0GYaoECDOnUPQlv9SJ3Fmqr5BnTqr6pyQQahxtNx2N3EGxvQePw5Shzr6JSoeiyUinerzH9VIeLP7vgpNyXyFXvriSHOJq9CoIFfnQSlEI8X7g1KVMh-k_f0SOWgFk55BHk8OuwbLWG30KAwM5htTqRMiEREkO0hbPkU1dxtKH7UUqHuztbP9jDnVCIh6kQRQR6PbBWstMYd0v9IDQh2zUpgPPAnsBqMCFpX-mMlXw9f9toUDy9iDj-c01ycJVT_qsFmdZHohWPbKxGpc4eqSLZAE8Y4pBWgK4rTCOCPi40jTuKR5VMkW7ksjJ1seHmZAABHsZ0xmGN291mN5sorh-qJ6Ck3zbqozJJfxWRgvEYP8tIEPAT383DXOBpve_Vj5dt688u7cRprfQyrQah0Fxlewu3olj1auIv8WIamiZO_8wl23_wR6ISt_n_lkfk7Z81uk3465fWjscmRFeozbWQ7QvVd4tRiWyuFBX6_Mps3wsor4_pbep6W1euyvaWSFRMd9YqfimeMzfOjUoX32UrzZ1hjRni4fRiU8rwoyq_Swk8UyUndg06v8ynQR0VWjjoinsMtI8Qa2zMa0Mc8hmI22becQvgc7-7rkvdX5Bda_m4vvyXjQoQZcZnoh1we-dd4YUFqkmlF7hjs1Jv3WIv1nOBb203V_W4yeFWx11mmmRp_tcSIFx5s2r0z5ngZgOU2gMWUo5pyx5_O7n2uijwFuFvZS_W_V5v6ZloSu3fmMz06Z405OSrzScm6_pbnSkp6r1aOzv-zj_Vp3ZZ3xz61UcQ-vyZb26xI46Ibdz5uOk5Yu0uxdhkZp2qXvXrVZ08U9ms3-Oa6yB-iUb1grkWoXo4oOo1-BUZzcz8gi04l9BX8Uth0b1UUktrMXIyqeh5nuyXI1qti7-2iI4mu0towlV3_S01dwBnp9loXJVW_BZrX3dWnft91q7czYpOlMz7ZtbbaqViyUtpOS0U0Wxs8quX76a2JrR0cdIsaQ8sJOvhRihV';
const url = 'https://fcm.googleapis.com/v1/projects/messageapp-75f3c/messages:send';

// Set up the message payload
const messagePayload = {
message: {
topic: "all_devices",
notification: {
title: "Broadcast Notification",
body: "This message is sent to all devices!"
},

android: {
priority: "high",
notification: {
channel_id: "high_importance_channel"
}
}
}
};

const headers ={
    'Authorization': `Bearer ${token}`,
    'Content-type': 'application/json'
};

axios.post(url,messagePayload,{headers}).then(response=>{
    console.log("Message sent successfully: ",response.data);
})
.catch(error=>{
console.error("error sending message", error.response?error.response.data:error.message);
});

