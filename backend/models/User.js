// [BENAR] Impor default dari database.js (adalah 'connection')
import db from '../config/database.js'; 
// [BENAR] Impor default dari bcryptjs
import bcrypt from 'bcryptjs';

class User {

  // --- FUNGSI HELPER "Find or Create Mapel" ---
  static _findOrCreateMapel(mapelName, callback) {
    const cleanMapelName = mapelName.trim();
    if (cleanMapelName.length === 0) {
      return callback({ message: 'Nama mapel tidak boleh kosong' }, null);
    }

    // Query ini sudah benar (di satu baris)
    const findQuery = 'SELECT mapel_id FROM mapel WHERE nama_mapel = ?'; 
    db.execute(findQuery, [cleanMapelName], (err, results) => {
      if (err) return callback(err, null);

      if (results.length > 0) {
        const mapel_id = results[0].mapel_id; 
        console.log(`Mapel ditemukan: ${cleanMapelName} (ID: ${mapel_id})`);
        return callback(null, mapel_id);
      } else {
        console.log(`Mapel TIDAK ditemukan. Membuat baru: ${cleanMapelName}`);
        // Query ini sudah benar (di satu baris)
        const insertQuery = 'INSERT INTO mapel (nama_mapel) VALUES (?)';
        db.execute(insertQuery, [cleanMapelName], (err, insertResult) => {
          if (err) return callback(err, null);
          const newMapelId = insertResult.insertId;
          console.log(`Mapel baru dibuat (ID: ${newMapelId})`);
          return callback(null, newMapelId); 
        });
      }
    });
  }


  // ========================
  // REGISTER (Bersih tanpa lokasi)
  // ========================
  static register(userData, callback) {
    const { name, username, email, password, role, subject } = userData;

    if (!role) return callback({ message: 'Role (guru/murid) harus diisi' }, null);
    if (!password || password.trim().length === 0) return callback({ message: 'Password tidak boleh kosong' }, null);
    
    const cleanPassword = password.trim();

    bcrypt.hash(cleanPassword, 10, (err, hashedPassword) => {
      if (err) return callback(err, null);

      if (role === 'guru') {
        // --- LOGIKA GURU ---
        if (!subject) return callback({ message: 'Guru harus mengisi mata pelajaran' }, null);

        db.execute('SELECT guru_id FROM akun_guru WHERE email = ?', [email], (err, results) => {
          if (err) return callback(err, null);
          if (results.length > 0) return callback({ message: 'Email guru sudah terdaftar' }, null);
          
          db.execute('SELECT guru_id FROM akun_guru WHERE username = ?', [username], (err, results) => {
            if (err) return callback(err, null);
            if (results.length > 0) return callback({ message: 'Username guru sudah terdaftar' }, null);

            User._findOrCreateMapel(subject, (err, mapel_id) => {
              if (err) return callback(err, null);

              // [BENAHI 1] Query HARUS dimulai di baris yang sama DAN menjadi satu baris
              const insertGuruQuery = `INSERT INTO akun_guru (name, username, email, password) VALUES (?, ?, ?, ?)`;
              
              db.execute(insertGuruQuery, [name, username, email, hashedPassword], (err, guruResult) => {
                  if (err) return callback(err, null);
                  const newGuruId = guruResult.insertId;

                  // [BENAHI 2] Query HARUS dimulai di baris yang sama DAN menjadi satu baris
                  const insertGuruMapelQuery = `INSERT INTO guru_mapel (guru_id, mapel_id) VALUES (?, ?)`;
                  
                  db.execute(insertGuruMapelQuery, [newGuruId, mapel_id], (err, mapelResult) => {
                      if (err) return callback({ message: 'Gagal menautkan mapel', error: err.message }, null);

                      callback(null, { 
                        id: newGuruId, name, username, email, role: 'guru', 
                        subject: subject
                      });
                  });
              });
            }); 
          });
        });

      } else if (role === 'murid') {
        // --- LOGIKA MURID ---
        db.execute('SELECT pengguna_id FROM akun_pengguna WHERE email = ?', [email], (err, results) => {
          if (err) return callback(err, null);
          if (results.length > 0) return callback({ message: 'Email murid terdaftar' }, null);
          
          db.execute('SELECT pengguna_id FROM akun_pengguna WHERE username = ?', [username], (err, results) => {
            if (err) return callback(err, null);
            if (results.length > 0) return callback({ message: 'Username murid terdaftar' }, null);
            
            // [BENAHI 3] Query HARUS dimulai di baris yang sama DAN menjadi satu baris
            const insertMuridQuery = `INSERT INTO akun_pengguna (name, username, email, password) VALUES (?, ?, ?, ?)`;
              
            db.execute(insertMuridQuery, [name, username, email, hashedPassword], (err, muridResult) => {
                if (err) return callback(err, null);
                callback(null, { 
                  id: muridResult.insertId, name, username, email, role: 'murid'
                });
            });
          });
        });
        
      } else {
        return callback({ message: 'Role tidak valid' }, null);
      }
    });
  }

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

// [BENAR] Menggunakan sintaks 'export default' ESM
export default User;