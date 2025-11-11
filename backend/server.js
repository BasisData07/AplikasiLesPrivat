// ================================
// File: backend/server.js
// ================================

// --- 1. IMPORT DEPENDENCIES ---
import express from 'express';
import cors from 'cors';
import { config } from 'dotenv';

// --- 2. IMPORT ROUTES ---
import authRoutes from './routes/auth.js';
import jadwalRoutes from './routes/jadwal.js';
import guruDataRoutes from './routes/guru_data.js';
import mapelRoutes from './routes/mapel.js'; // ✅ route mapel aktif
import profileRoutes from './routes/profile.js';


// --- 3. INISIALISASI APLIKASI ---
config(); // Muat variabel dari .env
const app = express(); // Buat instance express

// --- 4. MIDDLEWARE ---
app.use(cors());         // Izinkan akses antar domain (frontend ↔ backend)
app.use(express.json()); // Agar body JSON bisa dibaca
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static('public/uploads')); // Untuk mengakses file gambar secara publik

// --- 5. PENDAFTARAN ROUTES ---
app.use('/api/auth', authRoutes);
app.use('/api/jadwal', jadwalRoutes);
app.use('/api/guru-data', guruDataRoutes);
app.use('/api/mapel', mapelRoutes); // ✅ route mapel sudah aktif
app.use('/api/profile', profileRoutes); // Daftarkan route profile.js

// --- 6. ROUTE UTAMA (TES SERVER) ---
app.get('/api', (req, res) => {
  res.json({ message: 'Selamat datang di API Aplikasi Les Privat!' });
});

// --- 7. MENJALANKAN SERVER ---
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`🚀 Server berjalan di http://localhost:${PORT}`);
  console.log('✅ Rute API yang terdaftar:');
  console.log('   - /api');
  console.log('   - /api/auth/... (auth.js)');
  console.log('   - /api/jadwal/... (jadwal.js)');
  console.log('   - /api/guru-data/... (guru_data.js)');
  console.log('   - /api/mapel/... (mapel.js)');
  console.log('   - /api/upload-profile-picture (profile.js)'); // <-- Rute baru aktif!
});

