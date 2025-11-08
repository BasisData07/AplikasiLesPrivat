// File: backend/server.js

// --- 1. IMPOR SEMUA DI ATAS ---
import express, { json } from 'express';
import cors from 'cors';
import { config } from 'dotenv';

// Impor routes (sesuai standar ESM, diakhiri .js)
import authRoutes from './routes/auth.js';
import jadwalRoutes from './routes/jadwal.js';
import guruDataRoutes from './routes/guru_data.js';
import mapelRoutes from './routes/mapel.js'; // [TAMBAHAN] Mendaftarkan route mapel

// --- 2. INISIALISASI ---
config(); // Muat variabel .env
const app = express(); // Buat aplikasi express

// --- 3. MIDDLEWARE ---
app.use(cors()); // Izinkan cross-origin
app.use(json()); // Izinkan body parser JSON

// --- 4. ROUTES (Path SUDAH DIPERBAIKI) ---
// [BENAHI] Path API tidak boleh diakhiri .js
app.use('/api/auth', authRoutes);
app.use('/api/jadwal', jadwalRoutes);
app.use('/api/guru-data', guruDataRoutes);
app.use('/api/mapel', mapelRoutes); // [TAMBAHAN] Gunakan route mapel

// Route root untuk tes
app.get('/api', (req, res) => {
  res.json({ message: 'Selamat datang di API Aplikasi Les Privat!' });
});

// --- 5. JALANKAN SERVER ---
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`🚀 Server berjalan di http://localhost:${PORT}`);
  
  // [BENAHI] Logger disederhanakan agar jelas
  console.log('✅ Rute API yang terdaftar:');
  console.log(`   - /api`);
  console.log(`   - /api/auth/... (dari auth.js)`);
  console.log(`   - /api/jadwal/... (dari jadwal.js)`);
  console.log(`   - /api/guru-data/... (dari guru_data.js)`);
  console.log(`   - /api/mapel/... (dari mapel.js)`);
});