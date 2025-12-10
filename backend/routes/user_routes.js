import { Router } from 'express';
import User from '../models/User.js'; // PASTIKAN PATH & HURUF KAPITAL BENAR

const router = Router();

/* =========================================================
    (READ) Mengambil Nama Pengguna (Murid/Guru) berdasarkan ID
    Route: GET /:userId 
    Path Penuh: /api/users/:userId 
    ========================================================= */
router.get('/:userId', async (req, res) => { // <--- PERBAIKAN DI SINI! HILANGKAN '/users'
    const { userId } = req.params;
    console.log(`🔥 [GET] /users/${userId} HIT! (Correctly Routed)`);

    try {
        // Panggil method dari User Model (yang sudah diperbaiki querynya)
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