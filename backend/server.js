// ================================
// File: backend/server.js
// ================================

// --- 1. IMPORT DEPENDENCIES ---
import express from 'express';
import cors from 'cors';
import { config } from 'dotenv';
import path from 'path';     // <-- TAMBAH INI
import { fileURLToPath } from 'url'; //
import db from './config/database.js'; // Pastikan path import benar

// --- 2. IMPORT ROUTES ---
import authRoutes from './routes/auth.js';
import jadwalRoutes from './routes/jadwal.js';
import guruDataRoutes from './routes/guru_data.js';
import mapelRoutes from './routes/mapel.js'; // ✅ route mapel aktif
import profileRoutes from './routes/profile.js';
import ulasanRouter from './routes/ulasan.js';
import { startFirestoreListener } from './firebase_listener.js';
import userRouter from './routes/user_routes.js'; // <--- PASTIKAN INI DI-IMPORT


// --- 3. INISIALISASI APLIKASI ---
config(); // Muat variabel dari .env
const app = express(); // Buat instance express
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);


// --- 4. MIDDLEWARE ---
app.use(cors());         // Izinkan akses antar domain (frontend ↔ backend)
app.use(express.json()); // Agar body JSON bisa dibaca
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static('public/uploads')); // Untuk mengakses file gambar secara publik
app.use('/uploads', express.static(path.join(__dirname, 'public/uploads')));
//app.use('/uploads', express.static(path.join(__dirname, 'public', 'uploads')));
app.use((req, res, next) => {
  console.log(`🔥 [${new Date().toLocaleTimeString()}] Request Masuk: ${req.method} ${req.url}`);
  next();
});

// --- 5. PENDAFTARAN ROUTES ---
app.use('/api/auth', authRoutes);
app.use('/api/jadwal', jadwalRoutes);
app.use('/api/guru-data', guruDataRoutes);
app.use('/api/mapel', mapelRoutes); // ✅ route mapel sudah aktif
app.use('/api/profile', profileRoutes); // Daftarkan route profile.js
app.use('/api/ulasan', ulasanRouter); // Daftarkan route ulasan.js
app.use('/api/users', userRouter); // <--- Tambahkan ini

// --- 6. ROUTE UTAMA (TES SERVER) ---
/*app.get('/api', (req, res) => {
  res.json({ message: 'Selamat datang di API Aplikasi Les Privat!' });
});*/

// Rute Cek Kesehatan Database // Pastikan path import benar

app.get('/cek-db', async (req, res) => {
  try {
    // Coba minta jam sekarang ke database
    const [rows] = await db.execute('SELECT NOW() as waktu_server');
    res.json({
      status: 'AMAN',
      pesan: 'Database Terhubung!',
      waktu_mysql: rows[0].waktu_server
    });
  } catch (error) {
    res.status(500).json({
      status: 'BAHAYA',
      pesan: 'Database GAGAL Konek',
      error: error.message
    });
  }
});



// --- 7. MENJALANKAN SERVER ---
const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {

  startFirestoreListener();
  console.log(`🚀 Server terbuka untuk SEMUA IP di port ${PORT}`);
  console.log('✅ Rute API yang terdaftar:');
  console.log('   - /api');
  console.log('   - /api/auth/... (auth.js)');
  console.log('   - /api/jadwal/... (jadwal.js)');
  console.log('   - /api/guru-data/... (guru_data.js)');
  console.log('   - /api/mapel/... (mapel.js)');
  console.log('   - /api/upload-profile-picture (profile.js)'); 
  console.log('   - /api/update-profile (profile.js)'); // <-- Rute baru aktif!
  console.log('   - /api/ulasan/... (ulasan.js)');
  



  
});

