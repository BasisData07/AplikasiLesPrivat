import { Router } from 'express';
import bcryptjs from 'bcryptjs';
// Impor db connection (Promise pool)
import db from '../config/database.js'; 
// Impor Model User (yang sudah kita perbaiki tadi)
import User from '../models/User.js';

const router = Router();
const { hash, compare } = bcryptjs;

// Ambil method dari User Model
const { register, login, getGuruById, getPenggunaById, deleteGuruById, deletePenggunaById, getAll } = User;

console.log('✅ routes/auth.js loaded (Full Features: Delete, Update Direct, dll)');

// ========================
// REGISTER (Tetap menggunakan Model User)
// ========================
router.post('/register', (req, res) => {
    const { name, username, email, password, role, subject } = req.body;

    if (!name || !username || !email || !password || !role) {
        return res.status(400).json({ success: false, message: 'Semua field dasar harus diisi' });
    }

    if (role === 'guru' && (!subject || subject.trim() === '')) {
        return res.status(400).json({ success: false, message: 'Guru harus mengisi mata pelajaran' });
    }
    
    // Panggil Model (User.js menangani callback -> async di dalam)
    register({ name, username, email, password, role, subject }, (err, user) => {
        if (err) return res.status(400).json({ success: false, message: err.message });
        res.status(201).json({ success: true, message: 'Registrasi berhasil', data: user });
    });
});

// ========================
// LOGIN (Tetap menggunakan Model User)
// ========================
router.post('/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password)
        return res.status(400).json({ success: false, message: 'Email dan password harus diisi' });

    // Admin Hardcoded
    if (email === 'admin@privateaja.com' && password === 'admin123') {
        return res.json({
            success: true, message: 'Login admin berhasil',
            data: { id: 0, name: 'Administrator', username: 'admin', email: 'admin@privateaja.com', role: 'admin', subject: null }
        });
    }

    // Panggil Model
    login(email, password, (err, user) => {
        if (err) return res.status(400).json({ success: false, message: err.message });
        res.json({ success: true, message: 'Login berhasil', data: user });
    });
});

// ========================
// GET PROFILE
// ========================
router.get('/profile/:role/:id', (req, res) => {
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
});

// ========================
// UPDATE PASSWORD LANGSUNG (Route Custom)
// ========================
router.post('/update-password-direct', async (req, res) => {
    console.log('🔥 Route /update-password-direct dipanggil');

    try {
        const { email, new_password } = req.body; 
        if (!email || !new_password)
            return res.status(400).json({ success: false, message: 'Email dan password baru harus diisi' });

        const hashed = await hash(new_password, 10);

        // 1. Cek di GURU
        const [guruResults] = await db.execute('SELECT guru_id FROM akun_guru WHERE email = ?', [email]);

        if (guruResults.length > 0) {
            // Update Guru
            await db.execute('UPDATE akun_guru SET password = ? WHERE email = ?', [hashed, email]);
            return res.json({ success: true, message: 'Password guru berhasil diperbarui!' });
        } 
        
        // 2. Cek di MURID
        const [muridResults] = await db.execute('SELECT pengguna_id FROM akun_pengguna WHERE email = ?', [email]);
        
        if (muridResults.length > 0) {
            // Update Murid
            await db.execute('UPDATE akun_pengguna SET password = ? WHERE email = ?', [hashed, email]);
            return res.json({ success: true, message: 'Password murid berhasil diperbarui!' });
        }

        // 3. Tidak ketemu
        return res.status(404).json({ success: false, message: 'Email tidak ditemukan' });

    } catch (error) {
        console.error('❌ Update Password Direct Error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
    }
});

// ========================
// DELETE ACCOUNT (Route Custom - Sesuai permintaan Anda)
// Menggunakan metode DELETE yang lebih RESTful
// ========================
router.delete('/delete-account', async (req, res) => {
    console.log('🎯 /api/auth/delete-account ENDPOINT HIT!');

    try {
        // Ambil dari body karena ini bukan route params
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
            // 1. Ambil HANYA password untuk cek keamanan
            const [results] = await db.execute('SELECT password FROM akun_guru WHERE guru_id = ?', [userId]);
            
            if (results.length === 0) return res.status(404).json({ success: false, message: 'User guru tidak ditemukan' });

            const user = results[0];
            const isPasswordValid = await compare(password, user.password);
            
            if (!isPasswordValid) {
                return res.status(400).json({ success: false, message: 'Password salah' });
            }

            // 2. Jika password benar, panggil Model deleteGuruById
            deleteGuruById(userId, (err, result) => {
                if (err) return res.status(500).json({ success: false, message: 'Gagal menghapus akun guru' });
                res.json({ success: true, message: 'Akun guru berhasil dihapus' });
            });

        } else if (role === 'murid') {
            // --- Logika Hapus Murid ---
            // 1. Ambil HANYA password untuk cek keamanan
            const [results] = await db.execute('SELECT password FROM akun_pengguna WHERE pengguna_id = ?', [userId]);

            if (results.length === 0) return res.status(404).json({ success: false, message: 'User murid tidak ditemukan' });

            const user = results[0];
            const isPasswordValid = await compare(password, user.password);

            if (!isPasswordValid) {
                return res.status(400).json({ success: false, message: 'Password salah' });
            }

            // 2. Jika password benar, panggil Model deletePenggunaById
            deletePenggunaById(userId, (err, result) => {
                if (err) return res.status(500).json({ success: false, message: 'Gagal menghapus akun murid' });
                res.json({ success: true, message: 'Akun murid berhasil dihapus' });
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

// Pilihan: Menyediakan endpoint POST /delete-account untuk compatibility dengan klien lama
// router.post('/delete-account', router.delete('/delete-account')); // Uncomment jika diperlukan

// ========================
// LIST ALL AVAILABLE ENDPOINTS
// ========================
router.get('/endpoints', (req, res) => {
    const endpoints = [
        { method: 'POST', path: '/api/auth/register' },
        { method: 'POST', path: '/api/auth/login' },
        { method: 'POST', path: '/api/auth/update-password-direct' }, 
        { method: 'DELETE', path: '/api/auth/delete-account' },
        { method: 'GET', path: '/api/auth/profile/:role/:id' }, 
        { method: 'GET', path: '/api/auth/endpoints' },
        { method: 'GET', path: '/api/auth/users' }
    ];
    res.json({ success: true, endpoints: endpoints });
});

// ========================
// GET ALL USERS (for Admin)
// ========================
router.get('/users', (req, res) => {
    console.log('✅ /api/auth/users ENDPOINT HIT!');
    getAll((err, users) => {
        if (err) return res.status(500).json({ success: false, message: err.message });
        res.json({ success: true, data: users });
    });
});

export default router;