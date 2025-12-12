
import { Router } from 'express';
import db from '../config/database.js';

const router = Router();

// 🔥 ENDPOINT KHUSUS UTK FIX DATABASE (Update Nama Kolom ke pengguna_id)
router.get('/fix-migration', async (req, res) => {
    try {
        // Coba Add pengguna_id langsung (asumsi id_murid belum ada atau mau diganti)
        // Kita gunakan ADD COLUMN IF NOT EXISTS logic via catch
        await db.execute("ALTER TABLE jadwal_les ADD COLUMN pengguna_id INT NULL AFTER is_booked;");
        res.send("✅ Migration Success: Added pengguna_id column. (Old id_murid ignored if exists)");
    } catch (e) {
        // Jika error "Duplicate column", berarti sudah ada.
        res.send("Migration result: " + e.message);
    }
});

console.log('✅ routes/jadwal.js loaded (Async/Await Mode)');

/* =========================================================
    (CREATE) Guru membuat jadwal les baru
    ========================================================= */
router.post('/create', async (req, res) => {
    console.log('🔥 [POST] /api/jadwal/create HIT!');

    try {
        const { id_gurumapel, hari, jam_mulai, jam_selesai } = req.body;

        if (!id_gurumapel || !hari || !jam_mulai || !jam_selesai) {
            return res.status(400).json({ success: false, message: 'Semua field wajib diisi.' });
        }

        // 🔥 VALIDASI KEBERADAAN ID_GURUMAPEL
        // Cek apakah id_gurumapel benar-benar ada milik siapa pun (atau milik guru ybs jika mau lebih ketat)
        const [checkMapel] = await db.execute('SELECT id_gurumapel FROM guru_mapel WHERE id_gurumapel = ?', [id_gurumapel]);

        if (checkMapel.length === 0) {
            console.warn(`⚠️ id_gurumapel ${id_gurumapel} tidak ditemukan di database!`);
            return res.status(400).json({
                success: false,
                message: 'Data mapel guru tidak valid atau sudah dihapus. Silakan refresh halaman.'
            });
        }

        const query = 'INSERT INTO jadwal_les (id_gurumapel, hari, jam_mulai, jam_selesai) VALUES (?, ?, ?, ?)';

        const [result] = await db.execute(query, [id_gurumapel, hari, jam_mulai, jam_selesai]);

        res.status(201).json({
            success: true,
            message: 'Jadwal les berhasil dibuat.',
            insertId: result.insertId,
        });

    } catch (err) {
        console.error('❌ Error create jadwal:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});

/* =========================================================
    (READ) Murid melihat semua jadwal (Beranda Murid)
    ========================================================= */
router.get('/all', async (req, res) => {
    console.log('🔥 [GET] /jadwal/all HIT! (Complex Join)');

    try {
        const query = `
            SELECT 
                j.jadwal_id, 
                j.hari, 
                j.jam_mulai, 
                j.jam_selesai,
                j.is_booked, /* Status Ketersediaan */
                ag.username AS nama_guru, /* 🔥 Diubah dari ag.name (Asumsi username adalah nama tampilan) */
                ag.email AS email_guru, /* 🔥 DITAMBAHKAN: Kunci untuk filtering di Flutter */
                m.nama_mapel,
                COALESCE(l.nama_kota, 'Indonesia') AS kota, 
                COALESCE(kj.nama_jenjang, 'Umum') AS level

            FROM jadwal_les j
            JOIN guru_mapel gm ON j.id_gurumapel = gm.id_gurumapel
            JOIN akun_guru ag ON gm.guru_id = ag.guru_id
            JOIN mapel m ON gm.mapel_id = m.mapel_id
            LEFT JOIN kategori_jenjang kj ON gm.kategori_id = kj.kategori_id
            LEFT JOIN profile_guru pg ON ag.guru_id = pg.guru_id
            LEFT JOIN lokasi l ON pg.lokasi_id = l.lokasi_id
            
            ORDER BY j.jadwal_id DESC
        `;

        const [results] = await db.execute(query);

        res.json({ success: true, data: results });

    } catch (err) {
        console.error('❌ Error get all jadwal:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});

/* =========================================================
    (READ) Guru melihat jadwal miliknya saja
    ========================================================= */
router.get('/guru/:guru_id', async (req, res) => {
    const { guru_id } = req.params;
    console.log(`🔥 [GET] /jadwal/guru/${guru_id} HIT!`);

    try {
        const query =
            'SELECT j.*, m.nama_mapel ' +
            'FROM jadwal_les j ' +
            'JOIN guru_mapel gm ON j.id_gurumapel = gm.id_gurumapel ' +
            'JOIN mapel m ON gm.mapel_id = m.mapel_id ' +
            'WHERE gm.guru_id = ? ' +
            'ORDER BY j.jadwal_id DESC';

        const [results] = await db.execute(query, [guru_id]);

        res.json({ success: true, data: results });

    } catch (err) {
        console.error('❌ Error get jadwal guru:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});

/* =========================================================
    (UPDATE) Guru mengubah data detail jadwal (HARI/JAM/MAPEL)
    ========================================================= */
router.post('/update/:jadwal_id', async (req, res) => {
    const { jadwal_id } = req.params;
    const { hari, jam_mulai, jam_selesai, id_gurumapel } = req.body;

    console.log(`🔥 [POST] /jadwal/update/${jadwal_id} HIT!`);

    try {
        if (!hari || !jam_mulai || !jam_selesai || !id_gurumapel) {
            return res.status(400).json({ success: false, message: 'Field hari, jam, dan id_gurumapel wajib diisi.' });
        }

        const query =
            'UPDATE jadwal_les SET hari = ?, jam_mulai = ?, jam_selesai = ?, id_gurumapel = ? ' +
            'WHERE jadwal_id = ?';

        const [result] = await db.execute(query, [hari, jam_mulai, jam_selesai, id_gurumapel, jadwal_id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Jadwal tidak ditemukan.',
            });
        }

        res.json({ success: true, message: 'Jadwal les berhasil diupdate.' });

    } catch (err) {
        console.error('❌ Error update jadwal:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});

/* =========================================================
    (UPDATE STATUS) Guru mengubah status is_booked (CHECKLIST & ASSIGN)
    ========================================================= */
router.post('/status/:jadwal_id', async (req, res) => {
    const { jadwal_id } = req.params;
    const { is_booked, guru_id_pemilik, pengguna_id } = req.body; // 🔥 GANTI id_murid -> pengguna_id

    console.log(`🔥 [POST] /jadwal/status/${jadwal_id} HIT!`);
    console.log('📦 Body:', req.body);

    if (is_booked === undefined || !guru_id_pemilik) {
        return res.status(400).json({ success: false, message: 'Status dan ID pemilik wajib diisi.' });
    }

    try {
        // 🔥 UPDATE v2: Jika is_booked = 1, kita bisa assign pengguna_id (jika ada)
        // Jika is_booked = 0, kita set pengguna_id = NULL

        let query = '';
        let params = [];

        // UPDATE Logic:
        const setMuridPart = (is_booked && pengguna_id) ? ', j.pengguna_id = ? ' : ', j.pengguna_id = NULL ';

        query =
            'UPDATE jadwal_les j ' +
            'JOIN guru_mapel gm ON j.id_gurumapel = gm.id_gurumapel ' +
            'SET j.is_booked = ? ' + setMuridPart +
            'WHERE j.jadwal_id = ? AND gm.guru_id = ?';

        params = [(is_booked ? 1 : 0)];
        if (is_booked && pengguna_id) params.push(pengguna_id);
        params.push(jadwal_id, guru_id_pemilik);

        const [result] = await db.execute(query, params);

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Jadwal tidak ditemukan atau Anda bukan pemilik.',
            });
        }

        res.json({ success: true, message: 'Status jadwal berhasil diupdate.' });

    } catch (err) {
        console.error('❌ Error update status jadwal:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});

/* =========================================================
    (READ) JADWAL SPESIFIK MURID (Jadwal Saya)
    ========================================================= */
router.get('/murid/:murid_id', async (req, res) => {
    const { murid_id } = req.params;
    console.log(`🔥 [GET] /jadwal/murid/${murid_id} HIT!`);

    try {
        const query = `
            SELECT 
                j.jadwal_id, 
                j.hari, 
                j.jam_mulai, 
                j.jam_selesai,
                ag.username AS nama_guru,
                gm.guru_id,
                m.nama_mapel,
                j.is_booked
            FROM jadwal_les j
            JOIN guru_mapel gm ON j.id_gurumapel = gm.id_gurumapel
            JOIN akun_guru ag ON gm.guru_id = ag.guru_id
            JOIN mapel m ON gm.mapel_id = m.mapel_id
            WHERE j.pengguna_id = ? AND j.is_booked = 1
            ORDER BY j.hari ASC, j.jam_mulai ASC
        `;

        const [results] = await db.execute(query, [murid_id]);

        res.json({ success: true, data: results });

    } catch (err) {
        console.error('❌ Error get jadwal murid:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});




/* =========================================================
    (DELETE) Guru menghapus jadwal les
    ========================================================= */
router.post('/delete/:jadwal_id', async (req, res) => {
    const { jadwal_id } = req.params;
    const { guru_id_pemilik } = req.body;

    console.log(`🔥 [POST] /jadwal/delete/${jadwal_id} HIT!`);

    try {
        if (!guru_id_pemilik) {
            return res.status(400).json({ success: false, message: 'Verifikasi pemilik dibutuhkan.' });
        }

        const query =
            'DELETE j FROM jadwal_les j ' +
            'JOIN guru_mapel gm ON j.id_gurumapel = gm.id_gurumapel ' +
            'WHERE j.jadwal_id = ? AND gm.guru_id = ?';

        const [result] = await db.execute(query, [jadwal_id, guru_id_pemilik]);

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Jadwal tidak ditemukan atau Anda bukan pemilik.',
            });
        }

        res.json({ success: true, message: 'Jadwal les berhasil dihapus.' });

    } catch (err) {
        console.error('❌ Error delete jadwal:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});

export default router;