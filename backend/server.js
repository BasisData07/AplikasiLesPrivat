const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth');

const app = express();
const PORT = process.env.PORT || 5000;

// 🔥 PERBAIKAN CORS - lebih permisif untuk development
app.use(cors({
  origin: '*', // Untuk sementara, allow semua origin
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
}));

// Middleware
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);

// Test route
app.get('/', (req, res) => {
  res.json({ 
    message: 'Private Aja API is running!',
    timestamp: new Date().toISOString()
  });
});

// Handle preflight
app.options('*', cors());

app.listen(PORT, '0.0.0.0', () => { // 🔥 Listen on all interfaces
  console.log(`🚀 Server is running on port ${PORT}`);
  console.log(`🌐 Local: http://localhost:${PORT}`);
  console.log(`🌐 Network: http://YOUR_IP:${PORT}`);
});