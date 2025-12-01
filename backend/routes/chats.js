// routes/chat.js

import { Router } from 'express';
import db from '../config/database.js';

const router = Router();

/* =========================================================
    (CREATE) Simpan Pesan dari Firebase/Frontend ke MySQL
    Route: POST /api/chat/save-message
    ========================================================= */
router.post('/save-message', async (req, res) => {
    console.log('🔥 [POST] /chat/save-message HIT!');

    // Pastikan data yang diterima sesuai dengan format ChatMessageModel
    const { sender_id, receiver_id, content, timestamp, chat_room_id } = req.body;

    try {
        if (!sender_id || !receiver_id || !content || !chat_room_id) {
            return res.status(400).json({ success: false, message: 'Data pesan tidak lengkap.' });
        }

        // Query untuk menyimpan pesan ke tabel chat_messages
        const query = `
            INSERT INTO chat_messages (sender_id, receiver_id, content, timestamp, chat_room_id) 
            VALUES (?, ?, ?, NOW(), ?);
        `;

        await db.execute(query, [sender_id, receiver_id, content, chat_room_id]);

        res.json({ success: true, message: 'Pesan berhasil disimpan di MySQL.' });

    } catch (err) {
        console.error('❌ Error saving chat message:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});

// routes/chat.js (Tambahkan route ini)

/* =========================================================
    (READ) Mengambil Riwayat Pesan berdasarkan Chat Room ID
    Route: GET /api/chat/history/:roomId
    ========================================================= */
router.get('/history/:roomId', async (req, res) => {
    const { roomId } = req.params;
    console.log(`🔥 [GET] /chat/history/${roomId} HIT!`);

    try {
        const query = `
            SELECT message_id, sender_id, receiver_id, content, timestamp, is_read 
            FROM chat_messages 
            WHERE chat_room_id = ? 
            ORDER BY timestamp ASC;
        `;
        const [results] = await db.execute(query, [roomId]);

        res.json({ success: true, data: results });

    } catch (err) {
        console.error('❌ Error getting chat history:', err);
        res.status(500).json({ success: false, message: 'Database error', error: err.message });
    }
});

export default router;