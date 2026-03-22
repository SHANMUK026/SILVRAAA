const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

router.get('/profile', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, email, phone, full_name, username, kyc_status, created_at 
       FROM users WHERE id = $1`,
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = result.rows[0];
    const balanceResult = await pool.query(
      'SELECT gold_grams, silver_grams, gold_value_inr, silver_value_inr FROM balances WHERE user_id = $1',
      [req.user.userId]
    );
    const rewardsResult = await pool.query(
      'SELECT aura_coins, tier FROM rewards WHERE user_id = $1',
      [req.user.userId]
    );

    res.json({
      ...user,
      balance: balanceResult.rows[0] || { gold_grams: 0, silver_grams: 0, gold_value_inr: 0, silver_value_inr: 0 },
      rewards: rewardsResult.rows[0] || { aura_coins: 0, tier: 'bronze' },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

router.patch('/profile', [
  body('full_name').optional().trim(),
  body('username').optional().trim(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { full_name, username } = req.body;
    const updates = [];
    const values = [];
    let i = 1;

    if (full_name !== undefined) {
      updates.push(`full_name = $${i++}`);
      values.push(full_name);
    }
    if (username !== undefined) {
      updates.push(`username = $${i++}`);
      values.push(username);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updates.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(req.user.userId);

    await pool.query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = $${i}`,
      values
    );

    res.json({ message: 'Profile updated' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Update failed' });
  }
});

// KYC placeholder - integrate with DigiLocker API when ready
router.get('/kyc', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT kyc_status FROM users WHERE id = $1',
      [req.user.userId]
    );
    res.json({ status: result.rows[0]?.kyc_status || 'pending' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch KYC status' });
  }
});

router.post('/kyc/initiate', async (req, res) => {
  // TODO: Integrate DigiLocker KYC API
  res.json({
    message: 'KYC initiation - integrate DigiLocker API',
    redirect_url: null,
  });
});

module.exports = router;
