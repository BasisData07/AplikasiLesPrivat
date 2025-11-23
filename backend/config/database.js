// ================================
// File: backend/config/database.js (VERSI PROMISE / MODERN)
// ================================

// 1. PENTING: Tambahkan '/promise' di belakang mysql2
import mysql from 'mysql2/promise'; 
import 'dotenv/config';

// 2. Gunakan createPool (Lebih stabil daripada createConnection untuk API)
const db = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'aplikasi_les_mania',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Cek koneksi saat server nyala (Opsional, biar tenang)
db.getConnection()
  .then(conn => {
    console.log('✅ Database connected successfully (Mode Promise)');
    conn.release();
  })
  .catch(err => {
    console.error('❌ Database connection failed:', err);
  });

// =======================================================
// 💡 BAGIAN PENTING: WRAPPER EXECUTE
// =======================================================

// Kita buat fungsi pembungkus (wrapper) agar bisa dipakai dengan 'await'
export const execute = async (query, params) => {
  try {
    // mysql2/promise mengembalikan array: [hasil_data, info_field]
    // Kita ambil index ke-0 saja (hasil_data)
    const [results] = await db.execute(query, params);
    
    // Kembalikan hasilnya agar bisa dibaca controller (insertId, rows, dll)
    return results;
  } catch (err) {
    // Jika error query, tampilkan di terminal biar gampang debug
    console.error("SQL Error:", err.message);
    throw err; 
  }
};

export default db;