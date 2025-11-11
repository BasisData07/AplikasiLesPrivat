// ================================
// File: backend/routes/profile.js
// ================================

import express from 'express';
import multer from 'multer';
import path from 'path';
import { execute } from '../config/database.js';

const router = express.Router();

// --- Konfigurasi Multer (Penyimpanan File) ---
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'public/uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// Filter file - PERBAIKI INI
const fileFilter = (req, file, cb) => {
  const allowedMimes = [
    'image/jpeg', 
    'image/png', 
    'image/jpg',
    'application/octet-stream' // TAMBAHKAN INI UNTUK FALLBACK
  ];
  
  // Juga cek extension sebagai fallback
  const fileExtension = path.extname(file.originalname).toLowerCase();
  const allowedExtensions = ['.jpg', '.jpeg', '.png'];
  
  if (allowedMimes.includes(file.mimetype) || 
      allowedExtensions.includes(fileExtension)) {
    cb(null, true);
  } else {
    console.log('File ditolak - MIME:', file.mimetype, 'Ext:', fileExtension);
    cb(new Error(`Format file tidak didukung!`), false);
  }
};

const upload = multer({ 
  storage: storage,
  fileFilter: fileFilter,
  limits: { fileSize: 1024 * 1024 * 5 } // Batas 5MB
});

// --- RUTE UPLOAD FOTO PROFIL ---
// --- RUTE UPLOAD FOTO PROFIL ---
router.post('/upload-profile-picture', upload.single('profile_picture'), async (req, res) => {
  try {
    console.log('DEBUG - Body:', req.body);
    console.log('DEBUG - File:', req.file);

    const { user_id } = req.body;
    const file = req.file;

    // Validasi Input
    if (!file) {
      return res.status(400).json({ success: false, message: 'File gambar tidak ditemukan.' });
    }
    if (!user_id) {
      return res.status(400).json({ success: false, message: 'User ID tidak ditemukan.' });
    }

    // --- DEBUG: CEK USER EXISTS ---
    console.log('🔄 BEFORE UPDATE - user_id:', user_id, 'type:', typeof user_id);
    
    const userCheck = await execute('SELECT * FROM akun_guru WHERE guru_id = ?', [user_id]);
    console.log('👤 User exists:', userCheck.length > 0);
    
    if (userCheck.length === 0) {
      return res.status(400).json({ success: false, message: 'User tidak ditemukan!' });
    }

    // Buat URL publik
    const fileUrl = `/uploads/${file.filename}`;
    console.log('📁 File URL:', fileUrl);

    // Update database
    const query = `UPDATE akun_guru SET foto_profil_guru = ? WHERE guru_id = ?`;
    console.log('🔄 Executing query:', query);
    
    const result = await execute(query, [fileUrl, user_id]);
    console.log('✅ UPDATE result - affectedRows:', result.affectedRows);

    // Kirim respon sukses
    res.status(200).json({
      success: true,
      message: 'Foto profil berhasil diunggah!',
      url: fileUrl 
    });

  } catch (error) {
    console.error('Error saat upload profil:', error.message);
    res.status(500).json({ success: false, message: 'Terjadi error di server.', error: error.message });
  }
});


export default router;