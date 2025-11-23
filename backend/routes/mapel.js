import { Router } from 'express';
// Ubah import menjadi 'db' (Pool Promise)
import db from '../config/database.js';

const router = Router();

// --- [1] Ambil semua mapel ---
router.get('/', async (req, res) => {
  console.log('🔥 /api/mapel/ ENDPOINT HIT!');
  const query = 'SELECT mapel_id, nama_mapel FROM mapel ORDER BY nama_mapel ASC';

  try {
    // Gunakan await dan array destructuring
    const [results] = await db.execute(query);
    res.json({ success: true, data: results });

  } catch (err) {
    console.error('❌ Error get all mapel:', err);
    res.status(500).json({ success: false, message: 'Database error', error: err.message });
  }
});

// --- [2] Ambil mapel milik guru tertentu ---
router.get('/guru/:guruId', async (req, res) => {
  const { guruId } = req.params;
  console.log(`🔥 /api/mapel/guru/${guruId} HIT!`);

  const query = `
    SELECT m.mapel_id, m.nama_mapel
    FROM guru_mapel gm
    JOIN mapel m ON gm.mapel_id = m.mapel_id
    WHERE gm.guru_id = ?;
  `;

  try {
    const [results] = await db.execute(query, [guruId]);

    if (results.length === 0) {
      return res.json({
        success: false, // Atau true dengan data [], tergantung selera frontend
        message: 'Guru ini belum terdaftar mengajar mapel apapun.',
        data: [],
      });
    }

    res.json({ success: true, data: results });

  } catch (err) {
    console.error('❌ Error get mapel guru:', err);
    res.status(500).json({ success: false, message: 'Database error', error: err.message });
  }
});

export default router;