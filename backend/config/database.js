import mysql from 'mysql2';
import 'dotenv/config'; // Cara baru impor dotenv

const connection = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'aplikasi_les_mania'
});

connection.connect((err) => {
  if (err) {
    console.error('Error connecting to MySQL: ' + err.stack);
    return;
  }
  console.log('Connected to MySQL as id ' + connection.threadId);
});

// =======================================================
// 💡 BAGIAN PENTING ADA DI SINI
// =======================================================

// 1. Ambil fungsi 'execute' dari 'connection'
// 2. 'bind(connection)' sangat penting agar 'this' context-nya tidak rusak
// 3. Ekspor 'execute' sebagai NAMED EXPORT
export const execute = connection.execute.bind(connection);

// Ekspor koneksi itu sendiri sebagai DEFAULT EXPORT (jika diperlukan file lain)
export default connection;