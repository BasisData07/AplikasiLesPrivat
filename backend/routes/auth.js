const express = require('express');
const router = express.Router();
const User = require('../models/User');

// Register endpoint
router.post('/register', async (req, res) => {
  try {
    const { name, username, email, password, role, subject } = req.body;

    // Validation
    if (!name || !username || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Semua field harus diisi'
      });
    }

    User.register({ name, username, email, password, role, subject }, (err, user) => {
      if (err) {
        return res.status(400).json({
          success: false,
          message: err.message
        });
      }

      res.status(201).json({
        success: true,
        message: 'Registrasi berhasil',
        data: user
      });
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Login endpoint
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email dan password harus diisi'
      });
    }

    // Check for admin login
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
      if (err) {
        return res.status(400).json({
          success: false,
          message: err.message
        });
      }

      res.json({
        success: true,
        message: 'Login berhasil',
        data: user
      });
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get user profile
router.get('/profile/:id', async (req, res) => {
  try {
    const userId = req.params.id;

    User.getById(userId, (err, user) => {
      if (err) {
        return res.status(404).json({
          success: false,
          message: err.message
        });
      }

      res.json({
        success: true,
        data: user
      });
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Forgot password endpoint
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email harus diisi'
      });
    }

    // Cek apakah email terdaftar
    const checkEmailQuery = 'SELECT * FROM users WHERE email = ?';
    db.execute(checkEmailQuery, [email], (err, results) => {
      if (err) {
        return res.status(500).json({
          success: false,
          message: 'Database error'
        });
      }

      if (results.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Email tidak terdaftar'
        });
      }

      const user = results[0];
      
      // Generate reset token (sederhana untuk demo)
      const resetToken = Math.random().toString(36).substring(2) + Date.now().toString(36);
      
      // Simpan token ke database (buat table reset_tokens)
      const saveTokenQuery = 'INSERT INTO reset_tokens (email, token, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 1 HOUR))';
      db.execute(saveTokenQuery, [email, resetToken], (err) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Gagal membuat token reset'
          });
        }

        // 🔥 DISINI KIRIM EMAIL (implementasi nyata butuh service email)
        console.log('📧 Reset password token untuk', email, ':', resetToken);
        
        // Untuk demo, kita log token saja
        // Di production, kirim email dengan link reset
        
        res.json({
          success: true,
          message: 'Link reset password telah dikirim ke email Anda',
          token: resetToken // Hanya untuk development
        });
      });
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Reset password endpoint
router.post('/reset-password', async (req, res) => {
  try {
    const { token, newPassword } = req.body;

    if (!token || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Token dan password baru harus diisi'
      });
    }

    // Verifikasi token
    const verifyTokenQuery = 'SELECT * FROM reset_tokens WHERE token = ? AND expires_at > NOW() AND used = 0';
    db.execute(verifyTokenQuery, [token], (err, results) => {
      if (err) {
        return res.status(500).json({
          success: false,
          message: 'Database error'
        });
      }

      if (results.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Token tidak valid atau sudah kadaluarsa'
        });
      }

      const tokenData = results[0];
      const email = tokenData.email;

      // Hash password baru
      bcrypt.hash(newPassword, 10, (err, hashedPassword) => {
        if (err) {
          return res.status(500).json({
            success: false,
            message: 'Gagal mengenkripsi password'
          });
        }

        // Update password user
        const updatePasswordQuery = 'UPDATE users SET password = ? WHERE email = ?';
        db.execute(updatePasswordQuery, [hashedPassword, email], (err) => {
          if (err) {
            return res.status(500).json({
              success: false,
              message: 'Gagal mengupdate password'
            });
          }

          // Tandai token sebagai sudah digunakan
          const markTokenUsedQuery = 'UPDATE reset_tokens SET used = 1 WHERE token = ?';
          db.execute(markTokenUsedQuery, [token]);

          res.json({
            success: true,
            message: 'Password berhasil direset'
          });
        });
      });
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;

