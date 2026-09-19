import fs from 'fs';
import csv from 'csv-parser';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config();

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
// Using anon key, wait, anon key might not have insert permissions unless RLS allows it.
// Wait, I should probably use service_role key if available, or just hope anon key works for this admin script, or tell user to use service role key if needed. The env file only has SUPABASE_ANON_KEY.
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const CSV_FILE = 'upcoming_festivals_2026_2027.csv';
const results = [];

function getEnvLanguages(row, prefix) {
    const obj = {};
    for (const key of Object.keys(row)) {
        if (key.startsWith(prefix + '_')) {
            const lang = key.split('_')[1];
            if (row[key] && row[key].trim() !== '') {
                obj[lang] = row[key];
            }
        }
    }
    return obj;
}

if (!fs.existsSync(CSV_FILE)) {
    console.error(`CSV file not found: ${CSV_FILE}`);
    process.exit(1);
}

fs.createReadStream(CSV_FILE)
    .pipe(csv())
    .on('data', (data) => {
        const title = getEnvLanguages(data, 'title');
        const puja_vidhi_content = getEnvLanguages(data, 'content');
        
        // Remove prefix keys from the insert object
        const rowData = { ...data };
        for (const key of Object.keys(data)) {
            if (key.startsWith('title_') || key.startsWith('content_')) {
                delete rowData[key];
            }
        }

        // Add the JSONB objects
        if (Object.keys(title).length > 0) rowData.title = title;
        if (Object.keys(puja_vidhi_content).length > 0) rowData.puja_vidhi_content = puja_vidhi_content;

        results.push(rowData);
    })
    .on('end', async () => {
        console.log(`Parsed ${results.length} rows. Uploading to Supabase...`);
        let successCount = 0;
        let errorCount = 0;

        for (const row of results) {
            const { data, error } = await supabase
                .from('upcoming_festivals')
                .insert([row]);
            
            if (error) {
                console.error(`Error inserting row:`, error);
                errorCount++;
            } else {
                successCount++;
            }
        }
        
        console.log(`Upload complete. Success: ${successCount}, Errors: ${errorCount}`);
        process.exit(0);
    });
