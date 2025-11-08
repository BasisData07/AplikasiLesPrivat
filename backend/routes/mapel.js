// File: backend/routes/mapel.js
import { Router } from 'express';
import { execute } from '../config/database.js';

const router = Router();

// --- [1] Ambil semua mapel ---
router.get('/', (req, res) => {
  console.log('🔥 /api/mapel/ ENDPOINT HIT!');
  const query = 'SELECT mapel_id, nama_mapel FROM mapel ORDER BY nama_mapel ASC';

  execute(query, [], (err, results) => {
    if (err) {
      console.error('❌ Error get all mapel:', err);
      return res.status(500).json({ success: false, message: 'Database error' });
    }
    res.json({ success: true, data: results });
  });
});

// --- [2] Ambil mapel milik guru tertentu ---
router.get('/guru/:guruId', (req, res) => {
  const { guruId } = req.params;
  console.log(`🔥 /api/mapel/guru/${guruId} HIT!`);

  const query = `
    SELECT m.mapel_id, m.nama_mapel
    FROM guru_mapel gm
    JOIN mapel m ON gm.mapel_id = m.mapel_id
    WHERE gm.guru_id = ?;
  `;

  execute(query, [guruId], (err, results) => {
    if (err) {
      console.error('❌ Error get mapel guru:', err);
      return res.status(500).json({ success: false, message: 'Database error' });
    }

    if (results.length === 0) {
      return res.json({
        success: false,
        message: 'Guru ini belum terdaftar mengajar mapel apapun.',
        data: [],
      });
    }

    res.json({ success: true, data: results });
  });
});

export default router;
