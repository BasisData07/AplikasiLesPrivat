import { Router } from 'express';
import db from '../config/database.js';

const router = Router();

console.log('✅ routes/ulasan.js loaded');

/* =========================================================
    (READ) Mengambil SEMUA ulasan + balasan untuk Guru ID tertentu
    Route: GET /api/ulasan/guru/:guruId
    ========================================================= */

// routes/ulasan.js (Modifikasi router.get('/guru/:guruId'))

router.get('/guru/:guruId', async (req, res) => {
    const { guruId } = req.params;
    console.log(`🔥 [GET] /ulasan/guru/${guruId} HIT! (Mengambil Semua Ulasan)`);
    
    try {
        const query = `
            SELECT 
                ug.ulasan_id,
                ug.rating,
                ug.komentar,
                ug.created_at,
                agp.username AS nama_murid,
                bu.balasan AS balasan_guru, 
                bu.created_at AS balasan_at
            FROM ulasan_guru ug
            JOIN akun_pengguna agp ON ug.pengguna_id = agp.pengguna_id 
            LEFT JOIN balasan_ulasan bu ON ug.ulasan_id = bu.ulasan_id 
            
            /* 🔥 FILTER UTAMA DIBIARKAN: Hanya berdasarkan ID Guru */
            WHERE ug.guru_id = ?
            
            ORDER BY ug.created_at DESC;
        `;
        
        const [results] = await db.execute(query, [guruId]);
        
        res.json({ success: true, data: results });

    } catch (err) {
        console.error('❌ Error get ulasan:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});
    
    
    
/*router.get('/guru/:guruId', async (req, res) => {
    const { guruId } = req.params;
    console.log(`🔥 [GET] /ulasan/guru/${guruId} HIT!`);
    
    try {
        const query = `
            SELECT 
                ug.ulasan_id,
                ug.rating,
                ug.komentar,
                ug.created_at,
                agp.username AS nama_murid,
                bu.balasan AS balasan_guru, 
                bu.created_at AS balasan_at
            FROM ulasan_guru ug
            JOIN akun_pengguna agp ON ug.pengguna_id = agp.pengguna_id 
            LEFT JOIN balasan_ulasan bu ON ug.ulasan_id = bu.ulasan_id 
            
            /* 🔥 FILTER UNTUK GURU DASHBOARD: HANYA TAMPILKAN YANG BELUM DIBALAS 
            WHERE ug.guru_id = ? AND bu.balasan IS NULL 
            
            ORDER BY ug.created_at DESC;
        `;
        // Catatan: Jika Anda ingin agar route ini mengembalikan SEMUA ulasan (dibales atau belum),
        // hapus 'AND bu.balasan IS NULL' dan biarkan filtering di frontend.
        // Untuk dashboard "Menunggu Balasan", filtering ini adalah solusi terbaik.
        
        const [results] = await db.execute(query, [guruId]);
        
        res.json({ success: true, data: results });

    } catch (err) {
        console.error('❌ Error get ulasan:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});
// ... (Sisa kode tetap sama)*/

/* =========================================================
    (CREATE/UPDATE) Murid mengirim atau memperbarui ulasan
    Route: POST /api/ulasan/create
    ========================================================= */
router.post('/create', async (req, res) => {
    console.log('🔥 [POST] /ulasan/create HIT!');
    
    const { guru_id, pengguna_id, rating, komentar } = req.body; 

    try {
        if (!guru_id || !pengguna_id || !rating || !komentar) {
            return res.status(400).json({ success: false, message: 'Field wajib (guru_id, pengguna_id, rating, komentar) harus diisi.' });
        }

        // Cek apakah murid sudah pernah memberi ulasan
        const [existing] = await db.execute(
            'SELECT ulasan_id FROM ulasan_guru WHERE guru_id = ? AND pengguna_id = ?',
            [guru_id, pengguna_id]
        );

        if (existing.length > 0) {
            // Jika sudah ada, lakukan UPDATE (perbarui rating, komentar, dan waktu)
            const query = 'UPDATE ulasan_guru SET rating = ?, komentar = ?, created_at = NOW() WHERE ulasan_id = ?';
            await db.execute(query, [rating, komentar, existing[0].ulasan_id]);
            return res.json({ success: true, message: 'Ulasan berhasil diperbarui.' });
        }

        // Jika belum ada, lakukan INSERT
        const query = 'INSERT INTO ulasan_guru (guru_id, pengguna_id, rating, komentar) VALUES (?, ?, ?, ?)';
        await db.execute(query, [guru_id, pengguna_id, rating, komentar]);

        res.status(201).json({ success: true, message: 'Ulasan berhasil dikirim.' });

    } catch (err) {
        console.error('❌ Error create ulasan:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});

/* =========================================================
    (CREATE) Guru membalas ulasan
    Route: POST /api/ulasan/reply
    ========================================================= */
router.post('/reply', async (req, res) => {
    console.log('🔥 [POST] /ulasan/reply HIT!');
    
    const { ulasan_id, guru_id, balasan } = req.body; 

    try {
        if (!ulasan_id || !guru_id || !balasan) {
            return res.status(400).json({ success: false, message: 'ID ulasan, ID guru, dan balasan wajib diisi.' });
        }

        // 1. Cek kepemilikan dan apakah balasan sudah ada
        const [ulasanCheck] = await db.execute(
            'SELECT guru_id FROM ulasan_guru WHERE ulasan_id = ? AND guru_id = ?',
            [ulasan_id, guru_id]
        );
        const [balasanCheck] = await db.execute(
            'SELECT balasan_id FROM balasan_ulasan WHERE ulasan_id = ?',
            [ulasan_id]
        );

        if (ulasanCheck.length === 0) {
            return res.status(403).json({ success: false, message: 'Akses ditolak: Ulasan tidak ditemukan atau Anda bukan pemilik.' });
        }

        if (balasanCheck.length > 0) {
             // Jika balasan sudah ada, update saja
            const query = 'UPDATE balasan_ulasan SET balasan = ?, created_at = NOW() WHERE ulasan_id = ?';
            await db.execute(query, [balasan, ulasan_id]);
            return res.json({ success: true, message: 'Balasan berhasil diperbarui.' });
        }


        // 2. Insert balasan baru ke tabel balasan_ulasan
        const query = 'INSERT INTO balasan_ulasan (ulasan_id, guru_id, balasan) VALUES (?, ?, ?)';
        await db.execute(query, [ulasan_id, guru_id, balasan]);

        res.status(201).json({ success: true, message: 'Balasan berhasil dikirim.' });

    } catch (err) {
        console.error('❌ Error reply ulasan:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});

export default router;