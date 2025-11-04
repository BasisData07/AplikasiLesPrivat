const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Get list of students who have chatted with teacher
router.get('/guru/:guruId', async (req, res) => {
  try {
    const guruId = req.params.guruId;
    
    const query = `
      SELECT DISTINCT 
        u.id, 
        u.name, 
        u.username, 
        u.email,
        u.role,
        MAX(m.timestamp) as last_message_time
      FROM messages m
      JOIN users u ON m.sender_id = u.id OR m.receiver_id = u.id
      WHERE (m.sender_id = ? OR m.receiver_id = ?) 
        AND u.role = 'murid'
        AND u.id != ?
      GROUP BY u.id
      ORDER BY last_message_time DESC
    `;
    
    db.execute(query, [guruId, guruId, guruId], (err, results) => {
      if (err) {
        return res.status(500).json({
          success: false,
          message: 'Database error'
        });
      }
      
      res.json({
        success: true,
        data: results
      });
    });
    
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;