import { Router } from 'express';
const router = Router();

// [BENAHI 1] Impor 'User.js' (File ESM)
// Impor 'default export' (yaitu 'class User')
import User from '../models/User.js';
// 'Bongkar' static method dari class tersebut. Ini sudah benar.
const { register, login, getGuruById, getPenggunaById, deleteGuruById, deletePenggunaById, getAll } = User;

// [BENAHI 2] Impor 'bcryptjs' (Paket CJS)
// Paket ini masih CJS, jadi kita TETAP pakai 'workaround' CJS-ke-ESM. Ini sudah benar.
import bcryptjs from 'bcryptjs';
const { hash, compare } = bcryptjs;

// [BENAHI 3] Impor 'database.js' (File ESM)
// Kita sudah buat 'named export' bernama 'execute', jadi kita impor langsung.
import { execute } from '../config/database.js';

console.log('✅ routes/auth.js loaded (Custom ID & No-Token Logic)');

// ========================
// REGISTER (Bersih tanpa id_domisili)
// ========================
router.post('/register', async (req, res) => {
  try {
    const { name, username, email, password, role, subject } = req.body;

    if (!name || !username || !email || !password || !role) {
      return res.status(400).json({ success: false, message: 'Semua field dasar harus diisi' });
    }

    if (role === 'guru' && (!subject || subject.trim() === '')) {
      return res.status(400).json({ success: false, message: 'Guru harus mengisi mata pelajaran' });
    }
    
    register({ name, username, email, password, role, subject }, (err, user) => {
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
        success: true, message: 'Login admin berhasil',
        data: { id: 0, name: 'Administrator', username: 'admin', email: 'admin@privateaja.com', role: 'admin', subject: null }
      });
    }

    login(email, password, (err, user) => {
      if (err) return res.status(400).json({ success: false, message: err.message });
      res.json({ success: true, message: 'Login berhasil', data: user });
    });
  } catch (error) {
    console.error('❌ Login Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ========================
// GET PROFILE (MODIFIED)
// ========================
router.get('/profile/:role/:id', async (req, res) => {
  try {
    const { role, id } = req.params;

    if (role === 'guru') {
      getGuruById(id, (err, user) => {
        if (err) return res.status(404).json({ success: false, message: err.message });
        res.json({ success: true, data: user });
      });
    } else if (role === 'murid') {
      getPenggunaById(id, (err, user) => {
        if (err) return res.status(404).json({ success: false, message: err.message });
        res.json({ success: true, data: user });
      });
    } else {
      return res.status(400).json({ success: false, message: 'Role tidak valid (harus guru atau murid)' });
    }

  } catch (error) {
    console.error('❌ Profile Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ========================
// UPDATE PASSWORD LANGSUNG (MODIFIED)
// ========================
router.post('/update-password-direct', async (req, res) => {
  console.log('🔥 Route /update-password-direct (Lupa Password) dipanggil');

  try {
    const { email, new_password } = req.body; 
    if (!email || !new_password)
      return res.status(400).json({ success: false, message: 'Email dan password baru harus diisi' });

    const hashed = await hash(new_password, 10);

    // 1. Cek & update guru
    const checkGuruQuery = 'SELECT guru_id FROM akun_guru WHERE email = ?';
    execute(checkGuruQuery, [email], async (err, guruResults) => {
      if (err) return res.status(500).json({ success: false, message: 'Database error (guru check)' });

      if (guruResults.length > 0) {
        // Ditemukan di guru, update
        const updateQuery = 'UPDATE akun_guru SET password = ? WHERE email = ?';
        execute(updateQuery, [hashed, email], (err2) => {
          if (err2) return res.status(500).json({ success: false, message: 'Gagal update password guru' });
          return res.json({ success: true, message: 'Password guru berhasil diperbarui!' });
        });
      } else {
        // 2. Jika tidak ada, Cek & update pengguna (murid)
        const checkPenggunaQuery = 'SELECT pengguna_id FROM akun_pengguna WHERE email = ?';
        execute(checkPenggunaQuery, [email], async (err, muridResults) => {
          if (err) return res.status(500).json({ success: false, message: 'Database error (murid check)' });
          
          if (muridResults.length > 0) {
            // Ditemukan di pengguna, update
            const updateQuery = 'UPDATE akun_pengguna SET password = ? WHERE email = ?';
            execute(updateQuery, [hashed, email], (err2) => {
              if (err2) return res.status(500).json({ success: false, message: 'Gagal update password murid' });
              return res.json({ success: true, message: 'Password murid berhasil diperbarui!' });
            });
          } else {
            // 3. Tidak ada di kedua tabel
            return res.status(404).json({ success: false, message: 'Email tidak ditemukan' });
          }
        });
      }
    });
  } catch (error) {
    console.error('❌ Update Password Direct Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ========================
// DELETE ACCOUNT (POST METHOD - VERSI BARU)
// ========================
router.post('/delete-account', async (req, res) => {
  console.log('🎯 /api/auth/delete-account ENDPOINT HIT!');

  try {
    const { userId, role, password } = req.body;
    console.log('📦 Received data:', { userId, role });

    if (!userId || !role || !password) {
      return res.status(400).json({
        success: false,
        message: 'Data tidak lengkap (membutuhkan userId, role, dan password)',
      });
    }

    if (role === 'guru') {
      // --- Logika Hapus Guru ---
      const getQuery = 'SELECT * FROM akun_guru WHERE guru_id = ?';
      execute(getQuery, [userId], async (err, results) => {
        if (err) return res.status(500).json({ success: false, message: 'DB error (get guru)' });
        if (results.length === 0) return res.status(404).json({ success: false, message: 'User guru tidak ditemukan' });

        const user = results[0];

        const isPasswordValid = await compare(password, user.password);
        if (!isPasswordValid) {
          return res.status(400).json({ success: false, message: 'Password salah' });
        }

        deleteGuruById(userId, (err, result) => {
           if (err) return res.status(500).json({ success: false, message: 'Gagal menghapus akun guru' });
          res.json({ success: true, message: 'Akun guru berhasil dihapus' });
        });
      });

    } else if (role === 'murid') {
      // --- Logika Hapus Murid (Pengguna) ---
      const getQuery = 'SELECT * FROM akun_pengguna WHERE pengguna_id = ?';
      
      execute(getQuery, [userId], async (err, results) => {
        if (err) return res.status(500).json({ success: false, message: 'DB error (get pengguna)' });
        if (results.length === 0) return res.status(404).json({ success: false, message: 'User murid tidak ditemukan' });

        const user = results[0];

        const isPasswordValid = await compare(password, user.password);
        if (!isPasswordValid) {
          return res.status(400).json({ success: false, message: 'Password salah' });
        }

        deletePenggunaById(userId, (err, result) => {
          if (err) return res.status(500).json({ success: false, message: 'Gagal menghapus akun murid' });
          res.json({ success: true, message: 'Akun murid berhasil dihapus' });
        });
      });
      
    } else {
      return res.status(400).json({ success: false, message: 'Role tidak valid' });
    }

  } catch (error) {
    console.error('❌ Delete account error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server: ' + error.message,
    });
  }
});

// ========================
// LIST ALL AVAILABLE ENDPOINTS (MODIFIED)
// ========================
router.get('/endpoints', (req, res) => {
  const endpoints = [
    { method: 'POST', path: '/api/auth/register' },
    { method: 'POST', path: '/api/auth/login' },
    { method: 'POST', path: '/api/auth/update-password-direct' }, 
    { method: 'DELETE', path: '/api/auth/delete-account' },
    { method: 'POST', path: '/api/auth/delete-account' }, 
    { method: 'GET', path: '/api/auth/profile/:role/:id' }, 
    { method: 'GET', path: '/api/auth/endpoints' },
    { method: 'GET', path: '/api/auth/users' }
  ];
  res.json({ success: true, endpoints: endpoints });
});

// ========================
// GET ALL USERS (for Admin)
// ========================
router.get('/users', async (req, res) => {
  console.log('✅ /api/auth/users ENDPOINT HIT!');
  try {
    getAll((err, users) => {
      if (err) return res.status(500).json({ success: false, message: err.message });
      res.json({ success: true, data: users });
    });
  } catch (error) {
    console.error('❌ Get All Users Error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  } // [BENAHI 5] Menghapus 'Li' dari 'Li }'
});

// [BENAHI 4] Menggunakan 'export default' ESM, bukan 'module.exports'
export default router;