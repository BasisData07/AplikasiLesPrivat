import db from '../config/database.js';
import bcrypt from 'bcryptjs';

class User {

  // --- HELPER: Cari atau Buat Mapel ID (Menggunakan Promise) ---
  static _getMapelIdPromise(mapelName) {
    return new Promise((resolve, reject) => {
      const cleanName = mapelName.trim();
      // Cek apakah mapel sudah ada
      db.execute('SELECT mapel_id FROM mapel WHERE nama_mapel = ?', [cleanName], (err, results) => {
        if (err) return reject(err);
        
        if (results.length > 0) {
          // Jika ada, kembalikan ID-nya
          resolve(results[0].mapel_id);
        } else {
          // Jika tidak ada, buat baru
          db.execute('INSERT INTO mapel (nama_mapel) VALUES (?)', [cleanName], (err, res) => {
            if (err) return reject(err);
            resolve(res.insertId);
          });
        }
      });
    });
  }

  // --- REGISTER (VERSI STABIL) ---
  static register(userData, callback) {
    const { name, username, email, password, role, subject } = userData;

    // Validasi dasar
    if (!role) return callback({ message: 'Role wajib diisi' }, null);
    if (!password) return callback({ message: 'Password wajib diisi' }, null);

    // Hash password
    bcrypt.hash(password, 10, async (err, hash) => {
      if (err) return callback({ message: 'Error hashing password' }, null);

      try {
        if (role === 'guru') {
          // --- ALUR REGISTRASI GURU ---
          if (!subject) return callback({ message: 'Guru wajib mengisi mata pelajaran' }, null);

          // 1. Pastikan Mapel ada dulu (tunggu sampai selesai)
          const mapelId = await User._getMapelIdPromise(subject);

          // 2. Masukkan data Guru
          const insertGuru = 'INSERT INTO akun_guru (name, username, email, password, subject) VALUES (?, ?, ?, ?, ?)';
          db.execute(insertGuru, [name, username, email, hash, subject], (err, resultGuru) => {
            if (err) {
               if (err.code === 'ER_DUP_ENTRY') return callback({ message: 'Email/Username guru sudah terdaftar' }, null);
               return callback(err, null);
            }
            
            const newGuruId = resultGuru.insertId;

            // 3. [VITAL] Hubungkan Guru dengan Mapel di tabel 'guru_mapel'
            const insertRelation = 'INSERT INTO guru_mapel (guru_id, mapel_id) VALUES (?, ?)';
            db.execute(insertRelation, [newGuruId, mapelId], (err) => {
               if (err) {
                 console.error('Gagal insert guru_mapel:', err);
                 return callback({ message: 'Registrasi berhasil tapi gagal set mapel. Hubungi admin.' }, null);
               }
               
               // SUKSES SEMPURNA!
               console.log(`✅ Guru baru terdaftar: ${username} (ID: ${newGuruId}) dengan Mapel ID: ${mapelId}`);
               callback(null, { id: newGuruId, name, email, role: 'guru', subject });
            });
          });

        } else if (role === 'murid') {
          // --- ALUR REGISTRASI MURID ---
          const insertMurid = 'INSERT INTO akun_pengguna (name, username, email, password) VALUES (?, ?, ?, ?)';
          db.execute(insertMurid, [name, username, email, hash], (err, res) => {
            if (err) {
               if (err.code === 'ER_DUP_ENTRY') return callback({ message: 'Email/Username murid sudah terdaftar' }, null);
               return callback(err, null);
            }
            console.log(`✅ Murid baru terdaftar: ${username} (ID: ${res.insertId})`);
            callback(null, { id: res.insertId, name, email, role: 'murid' });
          });

        } else {
          callback({ message: 'Role tidak valid' }, null);
        }
      } catch (error) {
        console.error('Register unexpected error:', error);
        callback({ message: 'Terjadi kesalahan server saat registrasi' }, null);
      }
    });
  }

  // ========================================================================
  // FUNGSI LAINNYA (Login, GetAll, dll) - Biarkan seperti semula atau 
  // gunakan yang sudah Anda miliki jika sudah berjalan baik.
  // ========================================================================
  // ... (Tempelkan sisa fungsi login, getGuruById, dll di sini jika perlu) ...

    // Login user (MODIFIED - Menggunakan ALIAS 'AS id')
  static login(email, password, callback) {
    
    const queryGuru = 'SELECT guru_id AS id, name, username, email, password, subject FROM akun_guru WHERE email = ?';
    db.execute(queryGuru, [email], (err, guruResults) => {
      if (err) return callback(err, null);

      if (guruResults.length > 0) {
        const user = guruResults[0]; 
        bcrypt.compare(password, user.password, (err, isMatch) => {
          if (err) return callback(err, null);
          if (!isMatch) {
            return callback({ message: 'Password salah' }, null);
          }
          const { password: _, ...userWithoutPassword } = user;
          userWithoutPassword.role = 'guru';
          callback(null, userWithoutPassword);
        });

      } else {
        const queryPengguna = 'SELECT pengguna_id AS id, name, username, email, password FROM akun_pengguna WHERE email = ?';
        db.execute(queryPengguna, [email], (err, muridResults) => {
          if (err) return callback(err, null);

          if (muridResults.length > 0) {
            const user = muridResults[0];
            bcrypt.compare(password, user.password, (err, isMatch) => {
              if (err) return callback(err, null);
              if (!isMatch) {
                return callback({ message: 'Password salah' }, null);
              }
              const { password: _, ...userWithoutPassword } = user;
              userWithoutPassword.role = 'murid';
              callback(null, userWithoutPassword);
            });

          } else {
            return callback({ message: 'Email tidak ditemukan' }, null);
          }
        });
      }
    });
  }

  // --- Fungsi Bawaan ID (MODIFIED) ---
  
  static getGuruById(userId, callback) {
    const query = 'SELECT guru_id AS id, name, username, email, subject FROM akun_guru WHERE guru_id = ?';
    db.execute(query, [userId], (err, results) => {
      if (err) return callback(err, null);
      if (results.length === 0) {
        return callback({ message: 'Guru tidak ditemukan' }, null);
      }
      results[0].role = 'guru';
      callback(null, results[0]);
    });
  }

  static getPenggunaById(userId, callback) {
    const query = 'SELECT pengguna_id AS id, name, username, email FROM akun_pengguna WHERE pengguna_id = ?';
    db.execute(query, [userId], (err, results) => {
      if (err) return callback(err, null);
      if (results.length === 0) {
        return callback({ message: 'Murid tidak ditemukan' }, null);
      }
      results[0].role = 'murid';
      callback(null, results[0]);
    });
  }

  static deleteGuruById(userId, callback) {
    const query = 'DELETE FROM akun_guru WHERE guru_id = ?';
    db.execute(query, [userId], (err, result) => {
      if (err) return callback(err, null);
      callback(null, result);
    });
  }

  static deletePenggunaById(userId, callback) {
    const query = 'DELETE FROM akun_pengguna WHERE pengguna_id = ?';
    db.execute(query, [userId], (err, result) => {
      if (err) return callback(err, null);
      callback(null, result);
    });
  }

  // Get all users (MODIFIED - Menggunakan ALIAS 'AS id' dan 'akun_pengguna')
  static getAll(callback) {
    // [BENAHI 4] Query HARUS dimulai di baris yang sama DAN menjadi satu baris
    const query = `(SELECT guru_id AS id, name, username, email, 'guru' AS role, subject, created_at FROM akun_guru) UNION ALL (SELECT pengguna_id AS id, name, username, email, 'murid' AS role, NULL AS subject, created_at FROM akun_pengguna) ORDER BY created_at DESC`;
    db.execute(query, (err, results) => {
      if (err) return callback(err, null);
      callback(null, results);
    });
  }
}

export default User;