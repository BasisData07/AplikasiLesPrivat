import { Router } from 'express';
const router = Router();

// [BENAHI] Gunakan impor 'named export' ESM secara langsung
import { execute } from '../config/database.js';

// Endpoint: GET /api/mapel/
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

export default router;