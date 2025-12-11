import db from '../config/database.js';
import bcrypt from 'bcryptjs';

class User {

    // --- HELPER: Cari atau Buat Mapel ID (Async/Await) ---
    static async _getMapelIdPromise(mapelName) {
        const cleanName = mapelName.trim();
        const [results] = await db.execute('SELECT mapel_id FROM mapel WHERE nama_mapel = ?', [cleanName]);

        if (results.length > 0) {
            return results[0].mapel_id;
        } else {
            const [res] = await db.execute('INSERT INTO mapel (nama_mapel) VALUES (?)', [cleanName]);
            return res.insertId;
        }
    }

    // --- REGISTER ---
    static register(userData, callback) {
        const { name, username, email, password, role, subject } = userData;

        if (!role) return callback({ message: 'Role wajib diisi' }, null);
        if (!password) return callback({ message: 'Password wajib diisi' }, null);

        bcrypt.hash(password, 10, async (err, hash) => {
            if (err) return callback({ message: 'Error hashing password' }, null);

            try {
                if (role === 'guru') {
                    if (!subject) return callback({ message: 'Guru wajib mengisi mata pelajaran' }, null);

                    // 1. Dapatkan ID Mapel
                    const mapelId = await User._getMapelIdPromise(subject);

                    // 2. Insert Guru
                    const insertGuru = 'INSERT INTO akun_guru (name, username, email, password, subject) VALUES (?, ?, ?, ?, ?)';

                    const [resultGuru] = await db.execute(insertGuru, [name, username, email, hash, subject]);
                    const newGuruId = resultGuru.insertId;

                    // 3. Hubungkan Guru & Mapel (DENGAN HARGA DEFAULT)
                    // Pastikan di DB, kolom harga pada tabel guru_mapel sudah diatur DEFAULT 0 atau NULL,
                    // atau kita masukkan nilai default di sini.
                    const DEFAULT_HARGA = 25000; // Harga default per jam saat registrasi

                    // ✅ PERBAIKAN: Tambahkan kolom 'harga' dan nilainya
                    const insertRelation = 'INSERT INTO guru_mapel (guru_id, mapel_id, harga) VALUES (?, ?, ?)';
                    await db.execute(insertRelation, [newGuruId, mapelId, DEFAULT_HARGA]);

                    console.log(`✅ Guru registered: ${username} (ID: ${newGuruId})`);
                    callback(null, { id: newGuruId, name, email, role: 'guru', subject });

                } else if (role === 'murid') {
                    // Insert Murid
                    const insertMurid = 'INSERT INTO akun_pengguna (name, username, email, password) VALUES (?, ?, ?, ?)';
                    const [res] = await db.execute(insertMurid, [name, username, email, hash]);

                    console.log(`✅ Murid registered: ${username} (ID: ${res.insertId})`);
                    callback(null, { id: res.insertId, name, email, role: 'murid' });

                } else {
                    callback({ message: 'Role tidak valid' }, null);
                }
            } catch (error) {
                console.error('❌ Register Error:', error);
                if (error.code === 'ER_DUP_ENTRY') {
                    return callback({ message: 'Email atau Username sudah terdaftar' }, null);
                }
                callback({ message: 'Terjadi kesalahan server: ' + error.message }, null);
            }
        });
    }

    // --- LOGIN ---
    static async login(email, password, callback) {
        try {
            // 1. Cek Guru
            const queryGuru = 'SELECT guru_id AS id, name, username, email, password, subject FROM akun_guru WHERE email = ?';
            const [guruResults] = await db.execute(queryGuru, [email]);

            if (guruResults.length > 0) {
                const user = guruResults[0];
                const isMatch = await bcrypt.compare(password, user.password);
                if (!isMatch) return callback({ message: 'Password salah' }, null);

                const { password: _, ...userWithoutPassword } = user;
                userWithoutPassword.role = 'guru';
                return callback(null, userWithoutPassword);
            }

            // 2. Cek Murid
            const queryPengguna = 'SELECT pengguna_id AS id, name, username, email, password FROM akun_pengguna WHERE email = ?';
            const [muridResults] = await db.execute(queryPengguna, [email]);

            if (muridResults.length > 0) {
                const user = muridResults[0];
                const isMatch = await bcrypt.compare(password, user.password);
                if (!isMatch) return callback({ message: 'Password salah' }, null);

                const { password: _, ...userWithoutPassword } = user;
                userWithoutPassword.role = 'murid';
                return callback(null, userWithoutPassword);
            }

            return callback({ message: 'Email tidak ditemukan' }, null);

        } catch (err) {
            console.error("Login Error:", err);
            return callback(err, null);
        }
    }

    // --- GET BY ID ---
    static async getGuruById(userId, callback) {
        try {
            const query = 'SELECT guru_id AS id, name, username, email, subject FROM akun_guru WHERE guru_id = ?';
            const [results] = await db.execute(query, [userId]);

            if (results.length === 0) return callback({ message: 'Guru tidak ditemukan' }, null);
            results[0].role = 'guru';
            callback(null, results[0]);
        } catch (err) { callback(err, null); }
    }

    static async getPenggunaById(userId, callback) {
        try {
            const query = 'SELECT pengguna_id AS id, name, username, email FROM akun_pengguna WHERE pengguna_id = ?';
            const [results] = await db.execute(query, [userId]);

            if (results.length === 0) return callback({ message: 'Murid tidak ditemukan' }, null);
            results[0].role = 'murid';
            callback(null, results[0]);
        } catch (err) { callback(err, null); }
    }

    // --- DELETE ---
    static async deleteGuruById(userId, callback) {
        try {
            const [result] = await db.execute('DELETE FROM akun_guru WHERE guru_id = ?', [userId]);
            callback(null, result);
        } catch (err) { callback(err, null); }
    }

    static async deletePenggunaById(userId, callback) {
        try {
            const [result] = await db.execute('DELETE FROM akun_pengguna WHERE pengguna_id = ?', [userId]);
            callback(null, result);
        } catch (err) { callback(err, null); }
    }

    // --- GET ALL ---
    static async getAll(callback) {
        try {
            const query = `(SELECT guru_id AS id, name, username, email, 'guru' AS role, subject, created_at FROM akun_guru) UNION ALL (SELECT pengguna_id AS id, name, username, email, 'murid' AS role, NULL AS subject, created_at FROM akun_pengguna) ORDER BY created_at DESC`;
            const [results] = await db.execute(query);
            callback(null, results);
        } catch (err) { callback(err, null); }
    }


    // --- GET NAME BY ID (Untuk Chat/Panggilan Nama) ---
    static async getNameById(userId) {
        try {
            // 1. Coba cari di akun_pengguna (Murid)
            let query = 'SELECT username AS name FROM akun_pengguna WHERE pengguna_id = ?';
            let [results] = await db.execute(query, [userId]); 

            if (results.length > 0) {
                return results[0].name; // Mengembalikan username dengan alias 'name'
            }

            // 2. Jika tidak ditemukan, coba cari di akun_guru
            query = 'SELECT username AS name FROM akun_guru WHERE guru_id = ?';
            [results] = await db.execute(query, [userId]); 

            if (results.length > 0) {
                return results[0].name; // Mengembalikan username dengan alias 'name'
            }

            return null; // Tidak Ditemukan

        } catch (err) {
            console.error("❌ ERROR FINAL: MySQL query gagal di getNameById:", err);
            // Melemparkan error yang lebih informatif
            throw new Error("Gagal mengambil nama pengguna dari database: " + err.message);
        }
    }
}

export default User;