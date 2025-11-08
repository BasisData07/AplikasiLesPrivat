// [UBAH] Menggunakan sintaks 'import' dari ESM
import jwt from 'jsonwebtoken';

// [UBAH] Menggunakan 'import' dan WAJIB menyertakan ekstensi .js
import User from '../models/User.js'; 

const authMiddleware = async (req, res, next) => {
  try {
    // 1. Ambil token dari header
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    // 2. Cek jika token tidak ada
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No token provided.'
      });
    }

    // 3. Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');
    
    // 4. Cari user di database untuk memastikan user masih ada
    // Baris ini berasumsi User.findById ada (mis. dari Mongoose atau model custom)
    const user = await User.findById(decoded.userId || decoded.id);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User not found. Token invalid.'
      });
    }

    // 5. Tambahkan user data ke request object
    req.user = {
      id: user._id, // Asumsi ini dari MongoDB/Mongoose
      userId: user.userId, // jika ada custom userId
      email: user.email,
      role: user.role
    };

    // 6. Lanjut ke controller
    next();

  } catch (error) {
    console.error('Auth Middleware Error:', error);

    // Handle specific JWT errors
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token.'
      });
    }

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired.'
      });
    }

    // Generic error
    res.status(500).json({
      success: false,
      message: 'Authentication failed.'
    });
  }
};

// [UBAH] Menggunakan sintaks 'export default' dari ESM
export default authMiddleware;