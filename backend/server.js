const express = require('express');
const cors = require('cors');
require('dotenv').config();
const ip = require('ip'); // untuk menampilkan alamat IP jaringan

// Import routes
const authRoutes = require('./routes/auth');

const app = express();
const PORT = process.env.PORT || 5000;

// ============================
// 🔥 CORS Configuration (lebih permisif untuk development)
// ============================
app.use(cors({
  origin: '*', // ubah ke domain tertentu jika produksi
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
}));

// ============================
// Middleware
// ============================
app.use(express.json()); // parsing body JSON

// ============================
// Routes
// ============================
console.log('✅ Registering /api/auth routes...');
app.use('/api/auth', authRoutes);

// ============================
// Test route
// ============================
app.get('/', (req, res) => {
  res.json({ 
    message: '✅ Private Aja API is running!',
    timestamp: new Date().toISOString()
  });
});

// ============================
// Handle preflight (OPTIONS)
// ============================
app.options('*', cors());

// ============================
// 404 Handler (endpoint tidak ditemukan)
// ============================
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint tidak ditemukan'
  });
});

// ============================
// Global Error Handler
// ============================
app.use((err, req, res, next) => {
  console.error('🔥 SERVER ERROR:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: err.message
  });
});

// ============================
// Jalankan server (akses jaringan lokal juga)
// ============================
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server is running on port ${PORT}`);
  console.log(`🌐 Local:   http://localhost:${PORT}`);
  console.log(`🌐 Network: http://${ip.address()}:${PORT}`);
});
