
import db from './config/database.js';

async function migrate() {
    try {
        console.log('Migrating database...');
        // Add id_murid to jadwal_les if it doesn't exist
        const query = "ALTER TABLE jadwal_les ADD COLUMN id_murid INT NULL AFTER is_booked;";
        await db.execute(query);
        console.log('Migration successful: Added id_murid to jadwal_les');
    } catch (err) {
        if (err.code === 'ER_DUP_FIELDNAME') {
            console.log('Column id_murid already exists. Skipping.');
        } else {
            console.error('Migration failed:', err);
        }
    }
    process.exit();
}

migrate();
