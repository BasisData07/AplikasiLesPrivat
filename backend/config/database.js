import mysql from 'mysql2/promise'; 
import 'dotenv/config';

/*const db = mysql.createPool({
  // GANTI 'localhost' JADI '127.0.0.1'
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
  enableKeepAlive: true,
  keepAliveInitialDelay: 0
});*/

const db = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  user: process.env.DB_USER || 'root', 
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'aplikasi_les_mania',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0
});

db.getConnection()
  .then(conn => {
    console.log('✅ Database connected successfully (Mode Promise)');
    conn.release();
  })
  .catch(err => {
    console.error('❌ Database connection failed:', err);
  });

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