const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

// Get INR Balance and Assets
router.get('/balance', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT inr_wallet, gold_grams, silver_grams FROM balances WHERE user_id = $1',
      [req.user.userId]
    );
    res.json(result.rows[0] || { inr_wallet: 0, gold_grams: 0, silver_grams: 0 });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch balance' });
  }
});

// Link Bank Account
router.post('/bank', [
  body('account_holder_name').notEmpty(),
  body('bank_name').notEmpty(),
  body('account_number').isLength({ min: 9 }),
  body('ifsc_code').isLength({ min: 11, max: 11 }),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { account_holder_name, bank_name, account_number, ifsc_code } = req.body;
    
    await pool.query(
      `INSERT INTO bank_details (user_id, account_holder_name, bank_name, account_number, ifsc_code)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (user_id) DO UPDATE SET
         account_holder_name = EXCLUDED.account_holder_name,
         bank_name = EXCLUDED.bank_name,
         account_number = EXCLUDED.account_number,
         ifsc_code = EXCLUDED.ifsc_code,
         is_verified = false,
         updated_at = CURRENT_TIMESTAMP`,
      [req.user.userId, account_holder_name, bank_name, account_number, ifsc_code]
    );

    res.json({ message: 'Bank details linked successfully and awaiting verification.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to link bank account' });
  }
});

// Request Withdrawal
router.post('/withdraw', [
  body('amount').isFloat({ min: 100 }).withMessage('Minimum withdrawal is ₹100'),
], async (req, res) => {
  try {
    const { amount } = req.body;
    
    // 1. Check KYC Status
    const userResult = await pool.query('SELECT kyc_status FROM users WHERE id = $1', [req.user.userId]);
    if (userResult.rows[0].kyc_status !== 'approved') {
      return res.status(403).json({ error: 'Withdrawals are blocked until KYC is approved.' });
    }

    // 2. Check Balance
    const balanceResult = await pool.query('SELECT inr_wallet FROM balances WHERE user_id = $1', [req.user.userId]);
    const currentBalance = balanceResult.rows[0]?.inr_wallet || 0;
    if (amount > currentBalance) {
      return res.status(400).json({ error: 'Insufficient balance' });
    }

    // 3. Get Bank Details
    const bankResult = await pool.query('SELECT id FROM bank_details WHERE user_id = $1', [req.user.userId]);
    if (bankResult.rows.length === 0) {
      return res.status(400).json({ error: 'Please link a bank account first.' });
    }

    await pool.query('BEGIN');

    // 4. Deduct Balance
    await pool.query(
      'UPDATE balances SET inr_wallet = inr_wallet - $1 WHERE user_id = $2',
      [amount, req.user.userId]
    );

    // 5. Create Withdrawal Entry
    await pool.query(
      'INSERT INTO withdrawals (user_id, bank_detail_id, amount, status) VALUES ($1, $2, $3, $4)',
      [req.user.userId, bankResult.rows[0].id, amount, 'pending']
    );

    await pool.query('COMMIT');
    res.json({ message: 'Withdrawal request submitted successfully.' });

  } catch (err) {
    await pool.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: 'Withdrawal failed' });
  }
});

module.exports = router;
