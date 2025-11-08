import { Router } from 'express';
import { execute } from '../config/database.js';

const router = Router();

// ==================================================================
// (READ) Mendapatkan daftar "Mapel yang Saya Ajar" untuk Guru
// Dipanggil oleh: Flutter (JadwalProvider.fetchMapelGuru)
// ==================================================================
router.get('/mapel-saya/:guru_id', (req, res) => {
  const { guru_id } = req.params;
  console.log(`🔥 HIT: /api/guru-data/mapel-saya/${guru_id}`);

  const query = `
    SELECT 
      gm.id_gurumapel,  -- [PERBAIKAN VITAL] Ini wajib ada agar sesuai model Flutter!
      m.nama_mapel      -- Label untuk dropdown
    FROM guru_mapel gm
    JOIN mapel m ON gm.mapel_id = m.mapel_id 
    WHERE gm.guru_id = ?
  `;
  
  execute(query, [guru_id], (err, results) => {
    if (err) {
      console.error('❌ Error get mapel guru:', err);
      return res.status(500).json({ success: false, message: 'Database error' });
    }
    
    console.log(`✅ Mengirim ${results.length} mapel untuk Guru ID ${guru_id}`);
    res.json({ success: true, data: results });
  });
});

export default router;