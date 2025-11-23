// ================================
// File: backend/routes/profile.js
// ================================

import express from 'express';
import multer from 'multer';
import path from 'path';
import { execute } from '../config/database.js';

const router = express.Router();

// --- 1. KONFIGURASI UPLOAD FOTO (TETAP SAMA) ---
const storage = multer.diskStorage({
  destination: (req, file, cb) => { cb(null, 'public/uploads/'); },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req, file, cb) => {
  const allowedMimes = ['image/jpeg', 'image/png', 'image/jpg', 'application/octet-stream'];
  const fileExtension = path.extname(file.originalname).toLowerCase();
  if (allowedMimes.includes(file.mimetype) || ['.jpg', '.jpeg', '.png'].includes(fileExtension)) {
    cb(null, true);
  } else { cb(new Error(`Format file tidak didukung!`), false); }
};

const upload = multer({ storage: storage, fileFilter: fileFilter, limits: { fileSize: 1024 * 1024 * 5 } });

// --- RUTE UPLOAD FOTO (POST) ---
router.post('/upload-profile-picture', upload.single('profile_picture'), async (req, res) => {
  try {
    const { user_id } = req.body;
    const file = req.file;
    if (!file || !user_id) return res.status(400).json({ success: false, message: 'Data tidak lengkap.' });
    const fileUrl = file.filename; 
    await execute(`UPDATE akun_guru SET foto_profil_guru = ? WHERE guru_id = ?`, [fileUrl, user_id]);
    res.status(200).json({ success: true, message: 'Foto berhasil diupload!', url: fileUrl });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error server', error: error.message });
  }
});

// ============================================================
// 2. RUTE UPDATE INFO GURU (FIXED DENGAN PROMISE DB)
// ============================================================
router.put('/update-info/:id', async (req, res) => {
    const idGuru = req.params.id;
    const { bio_deskripsi, pengalaman_tahun, no_telpon, nama_instansi, posisi, domisili, harga_per_jam } = req.body;

    console.log(`\n--- UPDATE ID ${idGuru} ---`);

    try {
        // --- LOGIKA LOKASI ---
        let finalLokasiId = null;

        if (domisili) {
            // Cek apakah ada?
            const cek = await execute('SELECT lokasi_id FROM lokasi WHERE nama_kota = ?', [domisili]);
            
            if (cek.length > 0) {
                finalLokasiId = cek[0].lokasi_id;
                console.log(`-> Lokasi Lama ID: ${finalLokasiId}`);
            } else {
                // Insert Baru (Sekarang pasti ditunggu sampai selesai)
                const insert = await execute('INSERT INTO lokasi (nama_kota) VALUES (?)', [domisili]);
                finalLokasiId = insert.insertId;
                console.log(`-> Lokasi Baru ID: ${finalLokasiId}`);
            }
        }

        // --- LOGIKA PROFIL ---
        const cekProfil = await execute('SELECT profile_id FROM profile_guru WHERE guru_id = ?', [idGuru]);

        if (cekProfil.length > 0) {
            // UPDATE
            let sql = `UPDATE profile_guru SET deskripsi=?, tahun_ajar=?, no_telpon=?, nama_instansi=?, posisi=?`;
            let params = [bio_deskripsi, pengalaman_tahun, no_telpon, nama_instansi, posisi];
            
            if (finalLokasiId) {
                sql += `, lokasi_id=?`;
                params.push(finalLokasiId);
            }
            sql += ` WHERE guru_id=?`;
            params.push(idGuru);
            
            await execute(sql, params);
            console.log("-> Profil Updated");
        } else {
            // INSERT
            await execute(
                `INSERT INTO profile_guru (guru_id, deskripsi, tahun_ajar, no_telpon, nama_instansi, posisi, lokasi_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
                [idGuru, bio_deskripsi, pengalaman_tahun, no_telpon, nama_instansi, posisi, finalLokasiId]
            );
            console.log("-> Profil Created");
        }

        // --- LOGIKA HARGA ---
        if (harga_per_jam) {
            await execute(`UPDATE guru_mapel SET harga = ? WHERE guru_id = ?`, [harga_per_jam, idGuru]);
            console.log("-> Harga Updated");
        }

        res.json({ success: true, message: 'Berhasil disimpan' });

    } catch (error) {
        console.error("ERROR:", error);
        res.status(500).json({ success: false, message: error.message });
    }
});

// ============================================================
// 3. RUTE AMBIL DETAIL (GET)
// ============================================================
router.get('/detail/:id', async (req, res) => {
    const idGuru = req.params.id;
    try {
        const query = `
            SELECT 
                pg.deskripsi AS bio_deskripsi,
                pg.tahun_ajar AS pengalaman_tahun,
                pg.no_telpon,
                pg.nama_instansi,
                pg.posisi,
                pg.sertifikat AS file_sertifikat,
                l.nama_kota AS domisili,
                ag.foto_profil_guru AS foto_profile_url,
                ag.username AS nama_lengkap, 
                (SELECT harga FROM guru_mapel WHERE guru_id = ? LIMIT 1) AS harga_per_jam,
                GROUP_CONCAT(DISTINCT m.nama_mapel SEPARATOR ', ') AS list_mapel,
                GROUP_CONCAT(DISTINCT kj.nama_jenjang SEPARATOR ', ') AS list_jenjang
            FROM akun_guru ag
            LEFT JOIN profile_guru pg ON ag.guru_id = pg.guru_id
            LEFT JOIN lokasi l ON pg.lokasi_id = l.lokasi_id
            LEFT JOIN guru_mapel gm ON ag.guru_id = gm.guru_id
            LEFT JOIN mapel m ON gm.mapel_id = m.mapel_id
            LEFT JOIN kategori_jenjang kj ON gm.kategori_id = kj.kategori_id 
            WHERE ag.guru_id = ?
            GROUP BY ag.guru_id
        `;

        const result = await execute(query, [idGuru, idGuru]);

        if (result.length > 0) {
            const d = result[0];
            const cleanData = {
                nama_lengkap: d.nama_lengkap || "",
                bio_deskripsi: d.bio_deskripsi || "",
                pengalaman_tahun: d.pengalaman_tahun || 0,
                no_telpon: d.no_telpon || "",
                nama_instansi: d.nama_instansi || "",
                posisi: d.posisi || "",
                domisili: d.domisili || "",
                file_sertifikat: d.file_sertifikat || "",
                foto_profile_url: d.foto_profile_url || "",
                harga_per_jam: d.harga_per_jam || 0,
                list_mapel: d.list_mapel || "",
                list_jenjang: d.list_jenjang || ""
            };
            res.status(200).json({ success: true, data: cleanData });
        } else {
            res.status(200).json({ success: true, data: {} });
        }
    } catch (error) {
        res.status(500).json({ success: false, message: 'Gagal mengambil data', error: error.message });
    }
});

/*
// ============================================================
// 3. RUTE AMBIL DETAIL PROFIL LENGKAP (GET)
// ============================================================
router.get('/detail/:id', async (req, res) => {
    const idGuru = req.params.id;
    console.log(`Request Detail Guru ID: ${idGuru}`);

    try {
        // QUERY JOIN LENGKAP
        const query = `
            SELECT 
                -- Profile Guru
                pg.deskripsi AS bio_deskripsi,
                pg.tahun_ajar AS pengalaman_tahun,
                pg.no_telpon,
                pg.nama_instansi,
                pg.posisi,
                pg.sertifikat AS file_sertifikat, -- Sekarang sudah varchar, tidak perlu CAST
                
                -- Lokasi
                l.nama_kota AS domisili,

                -- Akun Guru
                ag.foto_profil_guru AS foto_profile_url,
                ag.username,
                -- Harga (Ambil dari GURU_MAPEL, sesuai permintaan)
                (SELECT harga FROM guru_mapel WHERE guru_id = ? LIMIT 1) AS harga_per_jam,

                -- List Mapel
                GROUP_CONCAT(DISTINCT m.nama_mapel SEPARATOR ', ') AS list_mapel,

                -- List Jenjang (SD/SMP)
                -- Pastikan tabel guru_mapel punya kolom 'jenjang_id' atau 'kategori_id'
                GROUP_CONCAT(DISTINCT kj.nama_jenjang SEPARATOR ', ') AS list_jenjang

            FROM akun_guru ag
            LEFT JOIN profile_guru pg ON ag.guru_id = pg.guru_id
            LEFT JOIN lokasi l ON pg.lokasi_id = l.lokasi_id
            LEFT JOIN guru_mapel gm ON ag.guru_id = gm.guru_id
            LEFT JOIN mapel m ON gm.mapel_id = m.mapel_id
            LEFT JOIN kategori_jenjang kj ON gm.kategori_id = kj.kategori_id 

            WHERE ag.guru_id = ?
            GROUP BY ag.guru_id
        `;

        const result = await execute(query, [idGuru, idGuru]);

        if (result.length > 0) {
            // Rapikan data (handle null)
            const d = result[0];
            const cleanData = {
                nama_lengkap: d.nama_lengkap || "",
                bio_deskripsi: d.bio_deskripsi || "",
                pengalaman_tahun: d.pengalaman_tahun || "",
                no_telpon: d.no_telpon || "",
                nama_instansi: d.nama_instansi || "",
                posisi: d.posisi || "",
                domisili: d.domisili || "",
                file_sertifikat: d.file_sertifikat || "",
                foto_profile_url: d.foto_profile_url || "",
                harga_per_jam: d.harga_per_jam || "", // Ini harga dari guru_mapel
                list_mapel: d.list_mapel || "",
                list_jenjang: d.list_jenjang || ""
            };

            res.status(200).json({ success: true, data: cleanData });
        } else {
            res.status(200).json({ success: true, data: {} });
        }

    } catch (error) {
        console.error('Error get detail:', error);
        res.status(500).json({ success: false, message: 'Gagal mengambil data', error: error.message });
    }
});*/

export default router;