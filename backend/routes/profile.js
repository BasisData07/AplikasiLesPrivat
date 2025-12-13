// ================================
// File: backend/routes/profile.js
// ================================

import express from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
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
// 2. RUTE UPDATE INFO GURU (FIXED LOKASI, JENJANG & HARGA)
// ============================================================
router.put('/update-info/:id', async (req, res) => {
    const idGuru = req.params.id;
    const { nama_lengkap, bio_deskripsi, pengalaman_tahun, no_telpon, nama_instansi, posisi, domisili, harga_per_jam, jenjang } = req.body;

    console.log(`\n--- UPDATE ID ${idGuru} ---`);
    console.log(`-> Jenjang Input: ${jenjang}`);
    console.log(`-> Harga Input: ${harga_per_jam}`);

    try {
        if (nama_lengkap) {
            await db.execute('UPDATE akun_guru SET username = ? WHERE guru_id = ?', [nama_lengkap, idGuru]);
            console.log(`-> Nama Updated: ${nama_lengkap}`);
        }

        // --- LOGIKA LOKASI (FIXED: MENCEGAH DUPLIKASI PADA MASTER LOKASI) ---
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
        // Fetch existing data to preserve if not provided
        const [cekProfil] = await db.execute('SELECT profile_id, nama_instansi, posisi, deskripsi, tahun_ajar, no_telpon FROM profile_guru WHERE guru_id = ?', [idGuru]);

        if (cekProfil.length > 0) {
            const existing = cekProfil[0];

            // Use input if provided (even empty string), otherwise fallback to existing, otherwise '-' for NOT NULL columns
            const valInstansi = nama_instansi !== undefined ? nama_instansi : (existing.nama_instansi || '-');
            const valPosisi = posisi !== undefined ? posisi : (existing.posisi || '-');
            const valDeskripsi = bio_deskripsi !== undefined ? bio_deskripsi : (existing.deskripsi || '');
            const valTahun = pengalaman_tahun !== undefined ? pengalaman_tahun : (existing.tahun_ajar || '');
            const valTelpon = no_telpon !== undefined ? no_telpon : (existing.no_telpon || '');

            let sql = `UPDATE profile_guru SET deskripsi=?, tahun_ajar=?, no_telpon=?, nama_instansi=?, posisi=?`;
            let params = [
                valDeskripsi,
                valTahun,
                valTelpon,
                valInstansi,
                valPosisi
            ];

            // finalLokasiId (Lokasi ID) MENIMPA ID lama di profile_guru
            if (finalLokasiId) { sql += `, lokasi_id=?`; params.push(finalLokasiId); }
            sql += ` WHERE guru_id=?`;
            params.push(idGuru);
            await db.execute(sql, params);
            console.log("-> Profil Updated");
        } else {
            // New Profile: Must provide defaults for NOT NULL columns
            await db.execute(
                `INSERT INTO profile_guru (guru_id, deskripsi, tahun_ajar, no_telpon, nama_instansi, posisi, lokasi_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
                [
                    idGuru,
                    bio_deskripsi || '',
                    pengalaman_tahun || '',
                    no_telpon || '',
                    nama_instansi || '-',
                    posisi || '-',
                    finalLokasiId
                ]
            );
            console.log("-> Profil Created");
        }

        // --- LOGIKA UTAMA PERBAIKAN: JENJANG & HARGA TERPISAH ---

        // 1. Ambil Kategori ID jika Jenjang di-update
        let selectedKategoriIds = [];
        if (jenjang && jenjang.length > 0) {
            // Normalisasi Input: Trim & Lowercase
            const rawJenjangs = jenjang.split(',').map(s => s.trim().toLowerCase()).filter(s => s.length > 0);

            // Fetch SEMUA Kategori (Data Master, jumlah sedikit, aman di-fetch semua)
            // Hindari masalah `IN (?)` pada db.execute yang terkadang tidak expand array
            const [allKategori] = await db.execute('SELECT kategori_id, nama_jenjang FROM kategori_jenjang');

            // Matching di JavaScript
            allKategori.forEach(dbJenjang => {
                const dbName = dbJenjang.nama_jenjang.toLowerCase();
                // Jika input user mengandung nama kategori ini
                if (rawJenjangs.includes(dbName)) {
                    selectedKategoriIds.push(dbJenjang.kategori_id);
                }
            });

            console.log(`-> Jenjang Cocok: ${selectedKategoriIds.length}/${rawJenjangs.length} item.`);

            if (selectedKategoriIds.length === 0) {
                console.log("-> Warning: Jenjang dipilih tapi tidak valid di DB.");
            }
        }

        // 2. Logika Update Mapping Guru-Mapel-Kategori-Harga
        // Cek mapel apa yang dimiliki guru ini
        // Ambil data mapel yang SUDAH ada
        const [existingMapel] = await db.execute(
            'SELECT mapel_id, MAX(harga) as harga FROM guru_mapel WHERE guru_id = ? GROUP BY mapel_id',
            [idGuru]
        );

        let mapelIdToUse = null;
        let currentPrice = 0;

        if (existingMapel.length > 0) {
            mapelIdToUse = existingMapel[0].mapel_id; // Ambil mapel pertama yg ditemukan
            currentPrice = existingMapel[0].harga;
        } else {
            // Jika belum ada di guru_mapel, ambil dari subject di akun_guru
            const [guruData] = await db.execute('SELECT subject FROM akun_guru WHERE guru_id = ?', [idGuru]);
            if (guruData.length > 0 && guruData[0].subject) {
                // Cari ID mapel dari nama subject
                const subjectName = guruData[0].subject;
                const [mRes] = await db.execute('SELECT mapel_id FROM mapel WHERE nama_mapel = ?', [subjectName]);
                if (mRes.length > 0) mapelIdToUse = mRes[0].mapel_id;
            }
        }

        // Tentukan Harga Baru (Input user > Harga Existing > Default 0)
        const newHarga = harga_per_jam ? parseInt(harga_per_jam) : (currentPrice || 0);

        // -- ACTION --
        if (mapelIdToUse) {

            // KASUS A: User update JENJANG (Maka reset mapping kategori)
            if (selectedKategoriIds.length > 0) {
                // Hapus mapping lama
                await db.execute(`DELETE FROM guru_mapel WHERE guru_id = ?`, [idGuru]);
                console.log("-> Reset guru_mapel untuk update Jenjang.");

                // Insert baru dengan Jenjang Baru & Harga (Baru/Lama)
                for (const katId of selectedKategoriIds) {
                    await db.execute(
                        `INSERT INTO guru_mapel (guru_id, mapel_id, kategori_id, harga) VALUES (?, ?, ?, ?)`,
                        [idGuru, mapelIdToUse, katId, newHarga]
                    );
                }
                console.log(`-> Sukses Update Jenjang & Harga (${newHarga})`);

            }
            // KASUS B: User TIDAK update JENJANG, tapi update HARGA
            // Update harga di semua entry guru_mapel yg ada
            else if (harga_per_jam) {
                await db.execute(
                    `UPDATE guru_mapel SET harga = ? WHERE guru_id = ?`,
                    [newHarga, idGuru]
                );
                console.log(`-> Sukses Update Harga Saja Menjadi: ${newHarga}`);
            }
            // KASUS C: Tidak ada jenjang input, tidak ada harga input -> Do nothing
            else {
                console.log("-> Tidak ada perubahan Jenjang/Harga diminta.");
            }

        } else {
            console.log("-> Error: Guru tidak memiliki Mapel dasar, tidak bisa set Jenjang/Harga.");
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
        COALESCE(AVG(ug.rating), 0) AS rating, 
        COALESCE(MAX(gm.harga), 0) AS harga_per_jam,
        GROUP_CONCAT(DISTINCT m.nama_mapel SEPARATOR ', ') AS list_mapel,
        GROUP_CONCAT(DISTINCT kj.nama_jenjang SEPARATOR ', ') AS list_jenjang
        FROM akun_guru ag
        LEFT JOIN profile_guru pg ON ag.guru_id = pg.guru_id
        LEFT JOIN lokasi l ON pg.lokasi_id = l.lokasi_id
        LEFT JOIN guru_mapel gm ON ag.guru_id = gm.guru_id
        LEFT JOIN mapel m ON gm.mapel_id = m.mapel_id
        LEFT JOIN kategori_jenjang kj ON gm.kategori_id = kj.kategori_id 
        LEFT JOIN ulasan_guru ug ON ag.guru_id = ug.guru_id
        WHERE ag.guru_id = ?
        GROUP BY ag.guru_id, pg.deskripsi, pg.tahun_ajar, pg.no_telpon, pg.nama_instansi, pg.posisi, pg.sertifikat, l.nama_kota, ag.foto_profil_guru, ag.username
        `;

        const [result] = await db.execute(query, [idGuru]);

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
                // Konversi eksplisit
                harga_per_jam: Number(d.harga_per_jam) || 0,
                rating: parseFloat(d.rating) || 0.0,
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
// 🔥 3.5. RUTE BARU: AMBIL SEMUA GURU (GET) - UNTUK BERANDA
// ============================================================
router.get('/detail', async (req, res) => {
    console.log('\n--- GET ALL GURU (DETAIL LIST) ---');

    try {
        const query = `
        SELECT 
        ag.guru_id AS id, 
        ag.email AS email, 
        ag.username AS nama_lengkap, 
        ag.foto_profil_guru, 
        pg.deskripsi,
        pg.tahun_ajar AS pengalaman_tahun,
        pg.no_telpon,
        l.nama_kota AS domisili,
        COALESCE(AVG(ug.rating), 0) AS rating, 
        COALESCE(MAX(gm.harga), 0) AS harga_per_jam,
        GROUP_CONCAT(DISTINCT m.nama_mapel SEPARATOR ', ') AS list_mapel,
        GROUP_CONCAT(DISTINCT kj.nama_jenjang SEPARATOR ', ') AS list_jenjang
        FROM akun_guru ag
        LEFT JOIN profile_guru pg ON ag.guru_id = pg.guru_id
        LEFT JOIN lokasi l ON pg.lokasi_id = l.lokasi_id
        LEFT JOIN guru_mapel gm ON ag.guru_id = gm.guru_id
        LEFT JOIN mapel m ON gm.mapel_id = m.mapel_id
        LEFT JOIN kategori_jenjang kj ON gm.kategori_id = kj.kategori_id
        LEFT JOIN ulasan_guru ug ON ag.guru_id = ug.guru_id
        
        GROUP BY ag.guru_id, ag.email, ag.username, ag.foto_profil_guru, pg.deskripsi, pg.tahun_ajar, pg.no_telpon, l.nama_kota
        ORDER BY ag.guru_id DESC; 
        `;

        const [results] = await db.execute(query);

        // Iterasi results untuk memastikan tipe data number
        const cleanResults = results.map(r => ({
            ...r,
            harga_per_jam: Number(r.harga_per_jam) || 0,
            rating: parseFloat(r.rating) || 0.0
        }));

        res.status(200).json({ success: true, data: cleanResults });

    } catch (error) {
        console.error("❌ ERROR Get All Guru:", error);
        res.status(500).json({ success: false, message: 'Kesalahan Server Internal: Gagal mengambil data guru', error: error.message });
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

            // Cek apakah file ada, lalu hapus secara Asynchronous (tanpa await)
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
        // Note: Idealnya, gunakan Foreign Key ON DELETE CASCADE di DB untuk relasi
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