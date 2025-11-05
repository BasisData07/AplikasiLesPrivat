// File: backend/server.js

const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Muat variabel lingkungan dari file .env
dotenv.config();

// Inisialisasi aplikasi Express
// PENTING: 'app' harus dibuat di sini, sebelum digunakan.
const app = express();

// Middleware
app.use(cors()); // Mengizinkan request dari domain lain (frontend Flutter Anda)
app.use(express.json()); // Mengizinkan aplikasi membaca body request dalam format JSON

// Routes
// Impor file route yang sudah Anda buat
const authRoutes = require('./routes/auth');

// Gunakan route tersebut dengan prefix '/api/auth'
// Semua request yang diawali '/api/auth' akan diarahkan ke auth.js
app.use('/api/auth', authRoutes);

// Route sederhana untuk root URL, untuk memastikan server berjalan
app.get('/api', (req, res) => {
  res.json({ message: 'Selamat datang di API Aplikasi Les Privat!' });
});

// Tentukan port dari environment variable atau default ke 5000
const PORT = process.env.PORT || 5000;

// Jalankan server
app.listen(PORT, () => {
  console.log(`🚀 Server berjalan di http://localhost:${PORT}`);

  // =================================================================
  // KODE UNTUK MELIHAT ENDPOINT SEBAIKNYA DITARUH DI SINI
  // Ini akan dieksekusi setelah server siap dan semua route terdaftar.
  // =================================================================
  console.log('✅ Endpoint yang terdaftar:');

  // Cek apakah _router sudah ada sebelum diakses
  if (app._router && app._router.stack) {
    app._router.stack.forEach((middleware) => {
      if (middleware.route) { // Hanya tampilkan yang merupakan route
        console.log(`   - ${Object.keys(middleware.route.methods).join(', ').toUpperCase()} ${middleware.route.path}`);
      }
    });
  }
});