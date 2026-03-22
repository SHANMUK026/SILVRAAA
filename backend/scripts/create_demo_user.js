require('dotenv').config();
const bcrypt = require('bcryptjs');
const pool = require('../src/config/db');

async function createDemoUser() {
  const email = 'demo@silvra.com';
  const phone = '9999999999';
  const password = 'password123';
  const fullName = 'Venu Silvra';
  
  try {
    const passwordHash = await bcrypt.hash(password, 10);
    
    // Check if user exists
    const existing = await pool.query('SELECT id FROM users WHERE phone = $1', [phone]);
    
    let userId;
    if (existing.rows.length > 0) {
      userId = existing.rows[0].id;
      console.log('Demo user already exists. Updating password...');
      await pool.query('UPDATE users SET password_hash = $1, full_name = $2 WHERE id = $3', [passwordHash, fullName, userId]);
    } else {
      const result = await pool.query(
        'INSERT INTO users (email, phone, password_hash, full_name, kyc_status) VALUES ($1, $2, $3, $4, $5) RETURNING id',
        [email, phone, passwordHash, fullName, 'approved']
      );
      userId = result.rows[0].id;
      console.log('Demo user created successfully.');
    }

    // Ensure balances exist
    await pool.query(
      'INSERT INTO balances (user_id, gold_grams, silver_grams, inr_wallet) VALUES ($1, $2, $3, $4) ON CONFLICT (user_id) DO NOTHING',
      [userId, 0.450, 12.5, 5000.00]
    );

    // Ensure rewards exist
    await pool.query(
      'INSERT INTO rewards (user_id, aura_coins, tier) VALUES ($1, $2, $3) ON CONFLICT (user_id) DO NOTHING',
      [userId, 150, 'gold']
    );

    console.log('\n--- DEMO CREDENTIALS ---');
    console.log(`Phone: ${phone}`);
    console.log(`Password: ${password}`);
    console.log('------------------------\n');
    
    process.exit(0);
  } catch (err) {
    console.error('Error creating demo user:', err);
    process.exit(1);
  }
}

createDemoUser();
