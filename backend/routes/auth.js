// ========================
// FILE: backend/routes/auth.js
// ========================

const express = require('express');
const router = express.Router();
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const db = require('../config/database'); // ✅ Mengacu ke database.js

console.log('✅ routes/auth.js loaded');

// ========================
// REGISTER
// ========================
router.post('/register', async (req, res) => {
  try {
    const { name, username, email, password, role, subject } = req.body;

    if (!name || !username || !email || !password) {
      return res.status(400).json({ success: false, message: 'Semua field harus diisi' });
    }

    User.register({ name, username, email, password, role, subject }, (err, user) => {
      if (err) return res.status(400).json({ success: false, message: err.message });
      res.status(201).json({ success: true, message: 'Registrasi berhasil', data: user });
    });
  } catch (error) {
    console.error('❌ Register Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ========================
// LOGIN
// ========================
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password)
      return res.status(400).json({ success: false, message: 'Email dan password harus diisi' });

    if (email === 'admin@privateaja.com' && password === 'admin123') {
      return res.json({
        success: true,
        message: 'Login admin berhasil',
        data: {
          id: 0,
          name: 'Administrator',
          username: 'admin',
          email: 'admin@privateaja.com',
          role: 'admin',
          subject: null
        }
      });
    }

    User.login(email, password, (err, user) => {
      if (err) return res.status(400).json({ success: false, message: err.message });
      res.json({ success: true, message: 'Login berhasil', data: user });
    });
  } catch (error) {
    console.error('❌ Login Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ========================
// GET PROFILE
// ========================
router.get('/profile/:id', async (req, res) => {
  try {
    const userId = req.params.id;
    User.getById(userId, (err, user) => {
      if (err) return res.status(404).json({ success: false, message: err.message });
      res.json({ success: true, data: user });
    });
  } catch (error) {
    console.error('❌ Profile Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ========================
// FORGOT PASSWORD
// ========================
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ success: false, message: 'Email harus diisi' });

    const checkEmailQuery = 'SELECT * FROM users WHERE email = ?';
    db.execute(checkEmailQuery, [email], (err, results) => {
      if (err) return res.status(500).json({ success: false, message: 'Database error' });
      if (results.length === 0)
        return res.status(404).json({ success: false, message: 'Email tidak terdaftar' });

      const resetToken = Math.random().toString(36).substring(2) + Date.now().toString(36);
      const saveTokenQuery = `
        INSERT INTO reset_tokens (email, token, expires_at)
        VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 1 HOUR))
      `;

      db.execute(saveTokenQuery, [email, resetToken], (err2) => {
        if (err2)
          return res.status(500).json({ success: false, message: 'Gagal membuat token reset' });

        console.log('📧 Token reset untuk', email, ':', resetToken);
        res.json({
          success: true,
          message: 'Link reset password telah dikirim ke email Anda',
          token: resetToken // hanya untuk dev/test
        });
      });
    });
  } catch (error) {
    console.error('❌ Forgot Password Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ========================
// RESET PASSWORD DENGAN TOKEN
// ========================
router.post('/reset-password', async (req, res) => {
  try {
    const { token, newPassword } = req.body;
    if (!token || !newPassword)
      return res.status(400).json({ success: false, message: 'Token dan password baru harus diisi' });

    const verifyTokenQuery = `
      SELECT * FROM reset_tokens
      WHERE token = ? AND expires_at > NOW() AND used = 0
    `;

    db.execute(verifyTokenQuery, [token], (err, results) => {
      if (err) return res.status(500).json({ success: false, message: 'Database error' });
      if (results.length === 0)
        return res.status(400).json({ success: false, message: 'Token tidak valid atau kadaluarsa' });

      const email = results[0].email;
      bcrypt.hash(newPassword, 10, (err, hashedPassword) => {
        if (err) return res.status(500).json({ success: false, message: 'Gagal mengenkripsi password' });

        const updatePasswordQuery = 'UPDATE users SET password = ? WHERE email = ?';
        db.execute(updatePasswordQuery, [hashedPassword, email], (err2) => {
          if (err2) return res.status(500).json({ success: false, message: 'Gagal mengupdate password' });
          db.execute('UPDATE reset_tokens SET used = 1 WHERE token = ?', [token]);
          res.json({ success: true, message: 'Password berhasil direset' });
        });
      });
    });
  } catch (error) {
    console.error('❌ Reset Password Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ========================
// UPDATE PASSWORD LANGSUNG TANPA TOKEN
// ========================
router.post('/update-password-direct', async (req, res) => {
  console.log('🔥 Route /update-password-direct dipanggil');

  try {
    const { email, new_password } = req.body;
    if (!email || !new_password)
      return res.status(400).json({ success: false, message: 'Email dan password baru harus diisi' });

    const checkQuery = 'SELECT * FROM users WHERE email = ?';
    db.execute(checkQuery, [email], async (err, results) => {
      if (err) return res.status(500).json({ success: false, message: 'Database error' });
      if (results.length === 0)
        return res.status(404).json({ success: false, message: 'Email tidak ditemukan' });

      const hashed = await bcrypt.hash(new_password, 10);
      const updateQuery = 'UPDATE users SET password = ? WHERE email = ?';
      db.execute(updateQuery, [hashed, email], (err2) => {
        if (err2)
          return res.status(500).json({ success: false, message: 'Gagal update password' });

        return res.json({ success: true, message: 'Password berhasil diperbarui!' });
      });
    });
  } catch (error) {
    console.error('❌ Update Password Direct Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;
