import { Router } from 'express';
const router = Router();

// [BENAHI 1] Impor 'execute' langsung dari file ESM database.js
import { execute } from '../config/database.js';

// ========================
// (READ) Mendapatkan daftar "Mapel yang Saya Ajar" untuk Guru
// ========================
router.get('/mapel-saya/:guru_id', (req, res) => {
  const { guru_id } = req.params;
  console.log(`🔥 /api/guru-data/mapel-saya/${guru_id} ENDPOINT HIT!`);

  // [BENAHI 2] Query diperbaiki
  const query = `
    SELECT 
      m.mapel_id,  -- Lebih berguna untuk dropdown (sebagai value)
      m.nama_mapel -- Lebih berguna untuk dropdown (sebagai label)
    FROM guru_mapel gm
    -- JOIN menggunakan 'mapel_id' (berdasarkan file User.js Anda)
    JOIN mapel m ON gm.mapel_id = m.mapel_id 
    WHERE gm.guru_id = ?
  `;
  
  execute(query, [guru_id], (err, results) => {
    if (err) {
      console.error('❌ Error get mapel guru:', err);
      return res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
    // Hasilnya: [ { mapel_id: 1, nama_mapel: "Matematika" }, ... ]
    res.json({ success: true, data: results });
  });
});

export default router;