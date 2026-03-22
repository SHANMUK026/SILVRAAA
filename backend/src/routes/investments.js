const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../config/db');
const { authMiddleware } = require('../middleware/auth');
const PriceService = require('../services/priceService');

const router = express.Router();

router.use(authMiddleware);

router.get('/balance', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM balances WHERE user_id = $1',
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.json({
        gold_grams: 0,
        silver_grams: 0,
        gold_value_inr: 0,
        silver_value_inr: 0,
      });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch balance' });
  }
});

router.post('/invest', [
  body('amount').isFloat({ min: 100 }).withMessage('Minimum investment ₹100'),
  body('asset_type').isIn(['gold', 'silver']),
  body('payment_method').optional(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { amount, asset_type, payment_method } = req.body;
    const referenceId = `INV${Date.now()}${Math.random().toString(36).substr(2, 6).toUpperCase()}`;

    await pool.query('BEGIN');

    // 1. GST Calculation (3%)
    const gstRate = 0.03;
    const gstAmount = amount * gstRate;
    const investableAmount = amount - gstAmount;

    // 2. Grams Calculation (Using Real-time Price from Service)
    const latestPrices = await PriceService.getLatestPrices();
    const currentPrice = asset_type === 'gold' ? latestPrices.gold : latestPrices.silver;
    
    const grams = investableAmount / currentPrice;

    // 3. Record Transaction with GST metadata
    await pool.query(
      `INSERT INTO transactions (user_id, type, amount, asset_type, quantity_grams, status, payment_method, reference_id, metadata) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [
        req.user.userId, 
        'invest', 
        amount, 
        asset_type, 
        grams, 
        'completed', 
        payment_method || 'upi', 
        referenceId, 
        JSON.stringify({ gst: gstAmount, base_price: investableAmount })
      ]
    );

    // 4. Update Balances (Transactional)
    await pool.query(
      `UPDATE balances SET 
        ${asset_type}_grams = ${asset_type}_grams + $1,
        ${asset_type}_value_inr = ${asset_type}_value_inr + $2,
        updated_at = CURRENT_TIMESTAMP
       WHERE user_id = $3`,
      [grams, investableAmount, req.user.userId]
    );

    await pool.query('COMMIT');

    res.status(201).json({
      success: true,
      reference_id: referenceId,
      amount,
      gst_paid: gstAmount,
      invested_value: investableAmount,
      asset_type,
      quantity_grams: grams,
    });
  } catch (err) {
    await pool.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: 'Investment failed' });
  }
});

router.post('/sell', [
  body('asset_type').isIn(['gold', 'silver']),
  body('quantity_grams').isFloat({ min: 0.0001 }),
], async (req, res) => {
  try {
    const { asset_type, quantity_grams } = req.body;
    
    await pool.query('BEGIN');

    // 1. Check Balance
    const balResult = await pool.query(
      `SELECT ${asset_type}_grams FROM balances WHERE user_id = $1`,
      [req.user.userId]
    );
    const available = balResult.rows[0]?.[`${asset_type}_grams`] || 0;
    
    if (quantity_grams > available) {
      return res.status(400).json({ error: `Insufficient ${asset_type} balance` });
    }

    // 2. Calculate Payout (Using Live Price)
    const prices = await PriceService.getLatestPrices();
    const currentPrice = asset_type === 'gold' ? prices.gold : prices.silver;
    const payoutAmount = quantity_grams * currentPrice;

    // 3. Record Transaction
    await pool.query(
      `INSERT INTO transactions (user_id, type, amount, asset_type, quantity_grams, status) 
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [req.user.userId, 'sell', payoutAmount, asset_type, quantity_grams, 'completed']
    );

    // 4. Update Balance
    await pool.query(
      `UPDATE balances SET 
        ${asset_type}_grams = ${asset_type}_grams - $1,
        inr_wallet = inr_wallet + $2,
        updated_at = CURRENT_TIMESTAMP
       WHERE user_id = $3`,
      [quantity_grams, payoutAmount, req.user.userId]
    );

    await pool.query('COMMIT');
    res.json({ success: true, payout_amount: payoutAmount, asset_type, quantity_grams });
  } catch (err) {
    await pool.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: 'Sell operation failed' });
  }
});

router.get('/transactions', async (req, res) => {
  try {
    const { type, limit = 50, offset = 0 } = req.query;

    let query = 'SELECT * FROM transactions WHERE user_id = $1';
    const params = [req.user.userId];

    if (type && ['gold', 'silver', 'withdraw', 'invest'].includes(type)) {
      params.push(type);
      query += ` AND (asset_type = $2 OR type = $2)`;
    }

    query += ' ORDER BY created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
    params.push(parseInt(limit), parseInt(offset));

    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch transactions' });
  }
});

router.post('/sip', [
  body('amount').isFloat({ min: 100 }),
  body('asset_type').isIn(['gold', 'silver']),
  body('frequency').isIn(['daily', 'weekly', 'monthly']),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { amount, asset_type, frequency } = req.body;
    
    let nextRun = new Date();
    if (frequency === 'daily') nextRun.setDate(nextRun.getDate() + 1);
    else if (frequency === 'weekly') nextRun.setDate(nextRun.getDate() + 7);
    else if (frequency === 'monthly') nextRun.setMonth(nextRun.getMonth() + 1);

    await pool.query(
      `INSERT INTO sips (user_id, asset_type, amount, frequency, next_run_at)
       VALUES ($1, $2, $3, $4, $5)`,
      [req.user.userId, asset_type, amount, frequency, nextRun]
    );

    res.status(201).json({ message: `Your ${frequency} SIP for ${asset_type} has been scheduled!`, nextRun });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to schedule SIP' });
  }
});

router.get('/sips', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM sips WHERE user_id = $1 ORDER BY created_at DESC',
      [req.user.userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch SIPs' });
  }
});

router.post('/auto-invest', [
  body('threshold_percentage').isFloat({ min: 1, max: 20 }),
  body('amount').isFloat({ min: 100 }),
  body('asset_type').isIn(['gold', 'silver']),
], async (req, res) => {
  try {
    const { threshold_percentage, amount, asset_type } = req.body;
    
    await pool.query(
      `INSERT INTO auto_invest_configs (user_id, asset_type, threshold_percentage, amount)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (user_id) DO UPDATE SET 
         asset_type = EXCLUDED.asset_type,
         threshold_percentage = EXCLUDED.threshold_percentage,
         amount = EXCLUDED.amount,
         updated_at = CURRENT_TIMESTAMP`,
      [req.user.userId, asset_type, threshold_percentage, amount]
    );

    res.json({ success: true, message: `Auto-Invest sequence set for ${asset_type} at ${threshold_percentage}% dip!` });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to set Auto-Invest' });
  }
});

module.exports = router;
