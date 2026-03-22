const express = require('express');
const pool = require('../config/db');
const auth = require('../middleware/auth');

const router = express.Router();

router.use(auth.authMiddleware);

// Get User Addresses
router.get('/addresses', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM addresses WHERE user_id = $1 ORDER BY is_default DESC, created_at DESC',
      [req.user.userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch addresses' });
  }
});

// Add New Address
router.post('/addresses', async (req, res) => {
  try {
    const { full_name, address_line_1, address_line_2, city, state, pincode, phone, is_default } = req.body;
    
    if (is_default) {
      await pool.query('UPDATE addresses SET is_default = false WHERE user_id = $1', [req.user.userId]);
    }

    const result = await pool.query(
      `INSERT INTO addresses (user_id, full_name, address_line_1, address_line_2, city, state, pincode, phone, is_default)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
      [req.user.userId, full_name, address_line_1, address_line_2, city, state, pincode, phone, is_default]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to add address' });
  }
});

// Place Delivery Order
router.post('/order', async (req, res) => {
  try {
    const { address_id, asset_type, grams, making_charges, delivery_fee } = req.body;
    const total_payable = parseFloat(making_charges) + parseFloat(delivery_fee);

    await pool.query('BEGIN');

    // 1. Check Asset Balance
    const balanceResult = await pool.query('SELECT gold_grams, silver_grams, inr_wallet FROM balances WHERE user_id = $1', [req.user.userId]);
    const balances = balanceResult.rows[0];
    const assetBalance = asset_type === 'gold' ? parseFloat(balances.gold_grams) : parseFloat(balances.silver_grams);

    if (grams > assetBalance) {
      throw new Error(`Insufficient ${asset_type} balance`);
    }

    if (total_payable > parseFloat(balances.inr_wallet)) {
      throw new Error('Insufficient INR wallet balance for making and delivery charges');
    }

    // 2. Deduct Asset & INR
    const assetCol = asset_type === 'gold' ? 'gold_grams' : 'silver_grams';
    await pool.query(
      `UPDATE balances SET ${assetCol} = ${assetCol} - $1, inr_wallet = inr_wallet - $2, updated_at = CURRENT_TIMESTAMP WHERE user_id = $3`,
      [grams, total_payable, req.user.userId]
    );

    // 3. Create Order
    const orderResult = await pool.query(
      `INSERT INTO delivery_orders (user_id, address_id, asset_type, grams, making_charges, delivery_fee, total_payable, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, 'pending') RETURNING *`,
      [req.user.userId, address_id, asset_type, grams, making_charges, delivery_fee, total_payable]
    );

    // 4. Record Transaction
    await pool.query(
      `INSERT INTO transactions (user_id, type, amount, asset_type, quantity_grams, status, metadata)
       VALUES ($1, 'DELIVERY_ORDER', $2, $3, $4, 'pending', $5)`,
      [req.user.userId, total_payable, asset_type, grams, JSON.stringify({ order_id: orderResult.rows[0].id })]
    );

    await pool.query('COMMIT');
    res.json({ success: true, order: orderResult.rows[0] });

  } catch (err) {
    await pool.query('ROLLBACK');
    console.error(err);
    res.status(400).json({ error: err.message || 'Delivery order failed' });
  }
});

module.exports = router;
