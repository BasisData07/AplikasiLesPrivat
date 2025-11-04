const db = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
  // Register user baru
  static register(userData, callback) {
    const { name, username, email, password, role, subject } = userData;
    
    // Check if email already exists
    const checkEmailQuery = 'SELECT id FROM users WHERE email = ?';
    db.execute(checkEmailQuery, [email], (err, results) => {
      if (err) return callback(err, null);
      if (results.length > 0) {
        return callback({ message: 'Email sudah terdaftar' }, null);
      }

      // Check if username already exists
      const checkUsernameQuery = 'SELECT id FROM users WHERE username = ?';
      db.execute(checkUsernameQuery, [username], (err, results) => {
        if (err) return callback(err, null);
        if (results.length > 0) {
          return callback({ message: 'Username sudah terdaftar' }, null);
        }

        // Hash password dan simpan user
        bcrypt.hash(password, 10, (err, hashedPassword) => {
          if (err) return callback(err, null);
          
          const insertQuery = `
            INSERT INTO users (name, username, email, password, role, subject) 
            VALUES (?, ?, ?, ?, ?, ?)
          `;
          
          db.execute(
            insertQuery, 
            [name, username, email, hashedPassword, role, subject],
            (err, results) => {
              if (err) return callback(err, null);
              
              // Get user data without password
              const getUserQuery = 'SELECT id, name, username, email, role, subject FROM users WHERE id = ?';
              db.execute(getUserQuery, [results.insertId], (err, userResults) => {
                if (err) return callback(err, null);
                callback(null, userResults[0]);
              });
            }
          );
        });
      });
    });
  }

  // Login user
  static login(email, password, callback) {
    const query = 'SELECT * FROM users WHERE email = ?';
    
    db.execute(query, [email], (err, results) => {
      if (err) return callback(err, null);
      if (results.length === 0) {
        return callback({ message: 'Email tidak ditemukan' }, null);
      }

      const user = results[0];
      
      // Verify password
      bcrypt.compare(password, user.password, (err, isMatch) => {
        if (err) return callback(err, null);
        if (!isMatch) {
          return callback({ message: 'Password salah' }, null);
        }

        // Remove password from user object
        const { password: _, ...userWithoutPassword } = user;
        callback(null, userWithoutPassword);
      });
    });
  }

  // Get user by ID
  static getById(userId, callback) {
    const query = 'SELECT id, name, username, email, role, subject FROM users WHERE id = ?';
    db.execute(query, [userId], (err, results) => {
      if (err) return callback(err, null);
      if (results.length === 0) {
        return callback({ message: 'User tidak ditemukan' }, null);
      }
      callback(null, results[0]);
    });
  }
}

module.exports = User;