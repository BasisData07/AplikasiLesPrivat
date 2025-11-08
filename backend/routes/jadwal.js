import { Router } from 'express';
const router = Router();

// [BENAHI] Impor 'execute' langsung dari file ESM database.js
// Cara impor CJS (CommonJS) lama Anda sudah tidak diperlukan lagi.
import { execute } from '../config/database.js';

// ========================
// (CREATE) Guru membuat jadwal les baru
// ========================
router.post('/create', (req, res) => {
  console.log('🔥 /api/jadwal/create ENDPOINT HIT!');
  const { id_gurumapel, hari, jam_mulai, jam_selesai } = req.body;

  if (!id_gurumapel || !hari || !jam_mulai || !jam_selesai) {
    return res.status(400).json({ success: false, message: 'Semua field wajib diisi' });
  }

  const query = `INSERT INTO jadwal_les 
    (id_gurumapel, hari, jam_mulai, jam_selesai)
    VALUES (?, ?, ?, ?)
  `;
  execute(query, [id_gurumapel, hari, jam_mulai, jam_selesai], (err, result) => {
    if (err) {
      console.error('❌ Error create jadwal:', err);
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
    res.status(201).json({ success: true, message: 'Jadwal les berhasil dibuat', insertId: result.insertId });
  });
});

// ========================
// (READ) Murid melihat SEMUA jadwal (Beranda Murid)
// ========================
router.get('/all', (req, res) => {
  console.log(`🔥 /api/jadwal/all ENDPOINT HIT!`);

  const query = `SELECT 
      j.jadwal_id, 
      j.hari,
      j.jam_mulai,
      j.jam_selesai,
      g.username AS nama_guru, 
      m.nama_mapel AS nama_mapel
    FROM jadwal_les j
    JOIN guru_mapel gm ON j.id_gurumapel = gm.id_gurumapel 
    JOIN akun_guru g ON gm.guru_id = g.guru_id
    JOIN mapel m ON gm.mapel_id = m.mapel_id
    ORDER BY j.jadwal_id DESC
  `;

  execute(query, [], (err, results) => {
    if (err) {
      console.error('❌ Error get all jadwal:', err);
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
    res.json({ success: true, data: results });
  });
});

// ========================
// (READ) Guru melihat jadwal yang DIA BUAT SAJA
// ========================
router.get('/guru/:guru_id', (req, res) => {
  const { guru_id } = req.params;
  console.log(`🔥 /api/jadwal/guru/${guru_id} ENDPOINT HIT!`);

  const query = `SELECT 
      j.*,
      m.nama_mapel
    FROM jadwal_les j
    JOIN guru_mapel gm ON j.id_gurumapel = gm.id_gurumapel
    JOIN mapel m ON gm.mapel_id = m.mapel_id
    WHERE gm.guru_id = ?
    ORDER BY j.jadwal_id DESC
  `;

  execute(query, [guru_id], (err, results) => {
    if (err) {
      console.error('❌ Error get jadwal guru:', err);
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
    res.json({ success: true, data: results });
  });
});

// ========================
// (UPDATE) Guru mengubah jadwal les
// ========================
router.post('/update/:jadwal_id', (req, res) => {
  const { jadwal_id } = req.params;
  const { hari, jam_mulai, jam_selesai, guru_id_pemilik } = req.body;

  console.log(`🔥 /api/jadwal/update/${jadwal_id} ENDPOINT HIT!`);

  if (!hari || !jam_mulai || !jam_selesai || !guru_id_pemilik) {
    return res.status(400).json({ success: false, message: 'Field wajib tidak boleh kosong' });
  }

  const query = `UPDATE jadwal_les j
    JOIN guru_mapel gm ON j.id_gurumapel = gm.id_gurumapel
    SET 
      j.hari = ?, 
      j.jam_mulai = ?, 
      j.jam_selesai = ?
    WHERE 
      j.jadwal_id = ? AND gm.guru_id = ?
  `;

  execute(query, [hari, jam_mulai, jam_selesai, jadwal_id, guru_id_pemilik], (err, result) => {
    if (err) {
      console.error('❌ Error update jadwal:', err);
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Jadwal tidak ditemukan atau Anda bukan pemilik' });
    }
    res.json({ success: true, message: 'Jadwal les berhasil diupdate' });
  });
});

// ========================
// (DELETE) Guru menghapus jadwal les
// ========================
router.post('/delete/:jadwal_id', (req, res) => {
  const { jadwal_id } = req.params;
  const { guru_id_pemilik } = req.body;

  console.log(`🔥 /api/jadwal/delete/${jadwal_id} ENDPOINT HIT!`);

  if (!guru_id_pemilik) {
    return res.status(400).json({ success: false, message: 'Verifikasi pemilik (guru_id_pemilik) dibutuhkan' });
  }

  const query = `DELETE j FROM jadwal_les j
    JOIN guru_mapel gm ON j.id_gurumapel = gm.id_gurumapel
  t WHERE 
      j.jadwal_id = ? AND gm.guru_id = ?
  `;

  execute(query, [jadwal_id, guru_id_pemilik], (err, result) => {
    if (err) {
      console.error('❌ Error delete jadwal:', err);
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Jadwal tidak ditemukan atau Anda bukan pemilik' });
  A }
    res.json({ success: true, message: 'Jadwal les berhasil dihapus' });
  });
});

// [BENAHI] Pastikan hanya ada SATU 'export default'
export default router;