import { Router } from 'express';
import User from '../models/User.js';

const router = Router();

/* =========================================================
    (READ) Ambil SEMUA User (Guru + Murid) untuk Admin
    Route: GET /all
    Path: /api/users/all
    ========================================================= */
router.get('/all', async (req, res) => {
    console.log('🔥 [GET] /users/all HIT!');
    try {
        // User.getAll uses helper callback style based on your model code
        User.getAll((err, results) => {
            if (err) {
                console.error("Error fetching all users:", err);
                return res.status(500).json({ success: false, message: 'Database error', error: err.message });
            }
            res.json({ success: true, data: results });
        });
    } catch (e) {
        res.status(500).json({ success: false, message: e.message });
    }
});

/* =========================================================
    (DELETE) Hapus User berdasarkan Role & ID
    Route: DELETE /:role/:userId
    Path: /api/users/:role/:userId
    ========================================================= */
router.delete('/:role/:userId', async (req, res) => {
    const { role, userId } = req.params;
    console.log(`🔥 [DELETE] /users/${role}/${userId} HIT!`);

    try {
        if (role === 'guru') {
            User.deleteGuruById(userId, (err, result) => {
                if (err) return res.status(500).json({ success: false, message: err.message });
                res.json({ success: true, message: 'Guru berhasil dihapus' });
            });
        } else if (role === 'murid') {
            User.deletePenggunaById(userId, (err, result) => {
                if (err) return res.status(500).json({ success: false, message: err.message });
                res.json({ success: true, message: 'Murid berhasil dihapus' });
            });
        } else {
            res.status(400).json({ success: false, message: 'Role tidak valid (guru/murid)' });
        }
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

/* =========================================================
    (READ) Mengambil Nama Pengguna (Murid/Guru) berdasarkan ID
    Route: GET /:userId 
    Path Penuh: /api/users/:userId 
    ========================================================= */
router.get('/:userId', async (req, res) => {
    const { userId } = req.params;

    // Prevent 'all' being captured here if express routing order fails (though it shouldn't)
    if (userId === 'all') return;

    console.log(`🔥 [GET] /users/${userId} HIT! (Correctly Routed)`);

    try {
        // Panggil method dari User Model
        const userName = await User.getNameById(userId);

        if (userName) {
            // Sukses: Mengembalikan format yang diharapkan Flutter: { "name": "Nama Pengguna" }
            return res.json({ success: true, name: userName });
        } else {
            // Tidak ditemukan di database
            return res.status(404).json({ success: false, message: 'Pengguna tidak ditemukan.' });
        }

    } catch (err) {
        // Error ini berasal dari MySQL (misalnya koneksi putus atau query gagal)
        console.error(`❌ Global Error fetching user ${userId}:`, err);
        return res.status(500).json({ success: false, message: 'Kesalahan Server Internal saat mengambil nama.', error: err.message });
    }
});

export default router;