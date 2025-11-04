const nodemailer = require('nodemailer');

// Konfigurasi transporter email
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER || 'your-email@gmail.com',  // Ganti dengan email Anda
    pass: process.env.EMAIL_PASS || 'your-app-password'     // Ganti dengan app password
  }
});

// Verify connection
transporter.verify((error, success) => {
  if (error) {
    console.log('❌ Email configuration error:', error);
  } else {
    console.log('✅ Email server is ready to send messages');
  }
});

module.exports = transporter;