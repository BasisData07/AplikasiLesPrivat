// ================================
// File: backend/routes/profile.js
// ================================

import express from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';        // <-- TAMBAH INI
import { fileURLToPath } from 'url'; //
import db from '../config/database.js';

const router = express.Router();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// --- KONFIGURASI UPLOAD FOTO (TETAP SAMA) ---
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
    
    await db.execute(`UPDATE akun_guru SET foto_profil_guru = ? WHERE guru_id = ?`, [fileUrl, user_id]);
    
    res.status(200).json({ success: true, message: 'Foto berhasil diupload!', url: fileUrl });
  } catch (error) {
    console.error('Upload Error:', error);
    res.status(500).json({ success: false, message: 'Error server', error: error.message });
  }
});

// ============================================================
// 2. RUTE UPDATE INFO GURU (FIXED LOKASI & JENJANG)
// ============================================================
router.put('/update-info/:id', async (req, res) => {
    const idGuru = req.params.id;
    const { bio_deskripsi, pengalaman_tahun, no_telpon, nama_instansi, posisi, domisili, harga_per_jam, jenjang } = req.body;

    console.log(`\n--- UPDATE ID ${idGuru} ---`);
    console.log(`-> Jenjang yang diterima: ${jenjang}`); // Debug Jenjang

    try {
        // --- LOGIKA LOKASI (FIXED: MENCEGAH DUPLIKASI PADA MASTER LOKASI) ---
        // Logika ini memastikan jika kota sudah ada (walau beda kapitalisasi), ID lama digunakan.
        let finalLokasiId = null;
        if (domisili) {
            // 1. Normalisasi input
            const inputDomisili = domisili.trim();
            const normalizedDomisili = inputDomisili.toLowerCase();
            
            // 2. Cari lokasi (dengan pencarian case-insensitive & trim-insensitive)
            const [cek] = await db.execute(
                'SELECT lokasi_id FROM lokasi WHERE LCASE(TRIM(nama_kota)) = ?',
                [normalizedDomisili]
            );
            
            if (cek.length > 0) {
                // Lokasi Ditemukan, gunakan ID yang ada
                finalLokasiId = cek[0].lokasi_id;
                console.log(`-> Lokasi Ditemukan, menggunakan ID: ${finalLokasiId}`);
            } else {
                // Lokasi BARU, buat entri baru di tabel master lokasi
                const displayNamaKota = inputDomisili.charAt(0).toUpperCase() + inputDomisili.slice(1).toLowerCase();
                const [insert] = await db.execute(
                    'INSERT INTO lokasi (nama_kota) VALUES (?)', 
                    [displayNamaKota]
                );
                finalLokasiId = insert.insertId;
                console.log(`-> Lokasi Baru Dibuat ID: ${finalLokasiId}`);
            }
        }
        // --- AKHIR LOGIKA LOKASI ---


        // --- LOGIKA PROFIL (Update/Insert profile_guru) ---
        const [cekProfil] = await db.execute('SELECT profile_id FROM profile_guru WHERE guru_id = ?', [idGuru]);

        if (cekProfil.length > 0) {
            let sql = `UPDATE profile_guru SET deskripsi=?, tahun_ajar=?, no_telpon=?, nama_instansi=?, posisi=?`;
            let params = [bio_deskripsi, pengalaman_tahun, no_telpon, nama_instansi, posisi];
            
            // finalLokasiId (Lokasi ID) MENIMPA ID lama di profile_guru
            if (finalLokasiId) { sql += `, lokasi_id=?`; params.push(finalLokasiId); }
            sql += ` WHERE guru_id=?`;
            params.push(idGuru);
            await db.execute(sql, params);
            console.log("-> Profil Updated");
        } else {
            await db.execute(
                `INSERT INTO profile_guru (guru_id, deskripsi, tahun_ajar, no_telpon, nama_instansi, posisi, lokasi_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
                [idGuru, bio_deskripsi, pengalaman_tahun, no_telpon, nama_instansi, posisi, finalLokasiId]
            );
            console.log("-> Profil Created");
        }

        // --- LOGIKA JENJANG & HARGA (FIXED QUERY & UPPERCASE) ---
        if (jenjang && jenjang.length > 0) {
            // 1. Pisahkan jenjang, paksa UPPERCASE (untuk mencegah error database)
            const selectedJenjangNames = jenjang.split(',').map(s => s.trim().toUpperCase());
            
            // PERBAIKAN UTAMA: Mengirim array langsung ke db.execute untuk query IN (?)
            const [kategoriResults] = await db.execute(
                `SELECT kategori_id FROM kategori_jenjang WHERE nama_jenjang IN (?)`,
                selectedJenjangNames // Tanpa [] pembungkus
            );
            const selectedKategoriIds = kategoriResults.map(r => r.kategori_id);
            
            if (selectedKategoriIds.length > 0) {
                // 2. Ambil mapel_id & harga lama
                const [mapelResults] = await db.execute(
                    `SELECT mapel_id, harga FROM guru_mapel WHERE guru_id = ? GROUP BY mapel_id`,
                    [idGuru]
                );
                
                const currentPrice = mapelResults.length > 0 ? mapelResults[0].harga : 0;
                const hargaToUse = harga_per_jam ? parseInt(harga_per_jam) : currentPrice;

                if (mapelResults.length > 0) {
                    // 3. Hapus dan Sisipkan kembali
                    await db.execute(`DELETE FROM guru_mapel WHERE guru_id = ?`, [idGuru]);
                        console.log("-> Data guru_mapel lama dihapus.");
                    for (const { mapel_id } of mapelResults) {
                        for (const kategoriId of selectedKategoriIds) {
                            await db.execute(
                                `INSERT INTO guru_mapel (guru_id, mapel_id, kategori_id, harga) VALUES (?, ?, ?, ?)`, 
                                [idGuru, mapel_id, kategoriId, hargaToUse]
                            );
                        }
                    }
                    console.log("-> Jenjang dan Harga Updated");
                } else {
                    console.log("-> Jenjang TIDAK di-update: Guru belum memiliki Mapel. Harga belum tersimpan.");
                }
            } else {
                console.log("-> Jenjang TIDAK di-update: Jenjang yang dipilih tidak valid di database.");
            }
        } else {
            console.log("-> Jenjang TIDAK di-update: Input Jenjang kosong. Data profil lainnya sudah disimpan.");
        }
        // --- AKHIR LOGIKA JENJANG & HARGA ---

        res.json({ success: true, message: 'Berhasil disimpan' });

    } catch (error) {
        console.error("ERROR Update Info:", error);
        res.status(500).json({ success: false, message: error.message });
    }
});

// ============================================================
// 3. RUTE AMBIL DETAIL (GET) - FIXED GROUP BY & JOIN LOKASI
// ============================================================
router.get('/detail/:id', async (req, res) => {
    const idGuru = req.params.id;
    // ... di dalam router.get('/detail/:id', async (req, res) => { ...

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
        GROUP BY ag.guru_id, pg.deskripsi, pg.tahun_ajar, pg.no_telpon, pg.nama_instansi, pg.posisi, pg.sertifikat, l.nama_kota, ag.foto_profil_guru, ag.username
        `; // Pastikan backtick (`) berada tepat di ujung baris terakhir

        const [result] = await db.execute(query, [idGuru, idGuru]); 
        
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
        console.error("ERROR Get Detail:", error);
        res.status(500).json({ success: false, message: 'Gagal mengambil data', error: error.message });
    }
});

// ============================================================
// 4. RUTE HAPUS PROFIL GURU (DELETE) - TERMASUK HAPUS FILE FISIK
// ============================================================
router.delete('/delete-profile/:id', async (req, res) => {
    const idGuru = req.params.id;

    try {
        console.log(`\n--- DELETE PROFILE ID ${idGuru} ---`);

        // 1. AMBIL NAMA FILE FOTO DARI DATABASE
        const [guru] = await db.execute(
            `SELECT foto_profil_guru FROM akun_guru WHERE guru_id = ?`, 
            [idGuru]
        );
        const fileName = guru.length > 0 ? guru[0].foto_profil_guru : null;
        
        // 2. HAPUS FILE FISIK DARI FOLDER public/uploads
        if (fileName && fileName.length > 0 && fileName !== 'default_avatar.png') {
            // Membuat path absolut: mundur satu folder dari /routes ke /backend, lalu ke /public/uploads
            const filePath = path.join(__dirname, '..', 'public', 'uploads', fileName); 
            
            console.log(`Mencoba menghapus file: ${filePath}`);
            
            // Cek apakah file ada, lalu hapus secara Asynchronous
            if (fs.existsSync(filePath)) {
                 fs.unlink(filePath, (err) => {
                    if (err) {
                        // Hanya log error, jangan hentikan proses DB delete
                        console.error("Gagal menghapus file foto:", err); 
                    } else {
                        console.log("-> File foto berhasil dihapus:", fileName);
                    }
                });
            } else {
                 console.log("-> File tidak ditemukan di path:", filePath);
            }
        } else {
            console.log("-> Tidak ada foto profil untuk dihapus atau menggunakan default.");
        }
        
        // 3. HAPUS RECORD DARI DATABASE (Order Penting: Relasi, Profil, Akun Utama)
        await db.execute(`DELETE FROM guru_mapel WHERE guru_id = ?`, [idGuru]);
        console.log("-> Data guru_mapel dihapus.");

        await db.execute(`DELETE FROM profile_guru WHERE guru_id = ?`, [idGuru]);
        console.log("-> Data profile_guru dihapus.");
        
        await db.execute(`DELETE FROM akun_guru WHERE guru_id = ?`, [idGuru]);
        console.log("-> Akun guru dihapus.");
        
        res.json({ success: true, message: 'Akun dan data terkait berhasil dihapus' });

    } catch (error) {
        console.error("ERROR Delete Profile:", error);
        res.status(500).json({ success: false, message: error.message });
    }
});


export default router;