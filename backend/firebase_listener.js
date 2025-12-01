// firebase_listener.js

import admin from 'firebase-admin';
import db from './config/database.js'; 
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs'; 

// Konversi URL modul ke path direktori
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 🔥 PATH FILE JSON (Pastikan nama file ini benar sesuai di folder backend kamu)
const SERVICE_ACCOUNT_FILE = path.join(__dirname, 'aplikasiprivateaja-16651-firebase-adminsdk-fbsvc-bc589f7a51.json');

// -------------------------------------------------------------
// INISIALISASI FIREBASE ADMIN SDK (SAFE MODE)
// -------------------------------------------------------------
async function initializeFirebaseAdmin() {
    // Cek apakah sudah terinisialisasi sebelumnya (Mencegah error saat restart)
    if (admin.apps.length > 0) {
        console.log('✅ Firebase Admin SDK already initialized.');
        return;
    }

    try {
        const serviceAccountJson = JSON.parse(fs.readFileSync(SERVICE_ACCOUNT_FILE, 'utf-8'));
        
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccountJson),
        });
        console.log('✅ Firebase Admin SDK Initialized Successfully.');
    } catch (error) {
        console.error('❌ FATAL: Failed to initialize Firebase Admin SDK.', error);
        process.exit(1); 
    }
}


// -------------------------------------------------------------
// FUNGSI SINKRONISASI KE MYSQL (SUDAH DIPERBAIKI)
// -------------------------------------------------------------
async function saveMessageToMySQL(data) {
    // 🔥 PERBAIKAN DISINI: Jumlah '?' harus sama dengan jumlah data di array
    const query = `
        INSERT INTO chat_messages 
        (sender_id, receiver_id, content, chat_room_id, timestamp, is_read) 
        VALUES (?, ?, ?, ?, NOW(), ?);
    `;
    
    // VALUES (?, ?, ?, ?, NOW(), ?) 
    // ? ke-1: sender_id
    // ? ke-2: receiver_id
    // ? ke-3: content
    // ? ke-4: chat_room_id (INI YANG TADI HILANG)
    // NOW(): timestamp (Otomatis MySQL)
    // ? ke-5: is_read

    try {
        await db.execute(query, [
            data.sender_id,
            data.receiver_id,
            data.content,
            data.chat_room_id,
            false // is_read (0)
        ]);
        console.log(`✅ [MySQL Sync] Saved message to room: ${data.chat_room_id}`);
    } catch (err) {
        console.error('🚨 [MySQL Sync] FAILED to save message:', err.message); 
    }
}


// -------------------------------------------------------------
// LISTENER FIRESTORE
// -------------------------------------------------------------
export async function startFirestoreListener() {
    await initializeFirebaseAdmin();
    
    const firestore = admin.firestore();
    
    // Opsi ini membantu koneksi agar tidak mudah putus di beberapa provider internet
    firestore.settings({ preferRest: true }); 

    console.log('🔍 Checking connection to Firestore...');

    // Tes koneksi awal
    try {
        await firestore.collectionGroup('messages').limit(1).get();
        console.log('✅ Connection Test Passed. Opening Real-time Stream...');
    } catch (error) {
        console.error('❌ KONEKSI GAGAL SAAT TEST. Cek internet/VPN/Jam Komputer.', error.message);
        return; 
    }

    console.log('👂 Starting Firestore Listener for new messages...');

    // Jalankan Listener
    const unsubscribe = firestore.collectionGroup('messages').onSnapshot(
        (snapshot) => { 
            snapshot.docChanges().forEach(change => {
                if (change.type === 'added') {
                    const newMessageData = change.doc.data();
                    
                    if (newMessageData.sender_id && newMessageData.content) {
                        
                        // Validasi path
                        if (!change.doc.ref.path) return;

                        const pathParts = change.doc.ref.path.split('/');
                        const roomId = pathParts.length > 1 ? pathParts[1] : 'unknown_room'; 
                        
                        const dataToSync = {
                            sender_id: newMessageData.sender_id,
                            receiver_id: newMessageData.receiver_id,
                            content: newMessageData.content,
                            chat_room_id: roomId,
                        };

                        saveMessageToMySQL(dataToSync);
                    }
                }
            });
        },
        (error) => {
            console.error('❌ STREAM ERROR TERDETEKSI:', error.code, error.message);
        }
    );
}