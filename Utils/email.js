const nodemailer = require('nodemailer');


const sendEmail = async (options) => {
    try {
        // Create transporter

        const transporter = nodemailer.createTransport({
            service: 'gmail',
            //port: process.env.EMAIL_PORT,
            auth: {
                user: 'raghadmatar2002@gmail.com',
                pass: 'npkb johb gxhx tgks',
            }
            
        });


        

        // Email options
        const emailOptions = {
            from: 'Qitaf Application <raghadmatar2002@gmail.com>',
            to: options.email,
            subject: options.subject,
            text: options.message,
        };

        // Send email
        await transporter.sendMail(emailOptions);
    } catch (err) {
        console.error('Error sending email:', err);
        throw new Error('Email could not be sent');
    }
};


module.exports=sendEmail;