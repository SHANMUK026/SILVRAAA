const express = require('express');
const { body, validationResult } = require('express-validator');
const { authMiddleware } = require('../middleware/auth');
const PaymentService = require('../services/paymentService');
const pool = require('../config/db');

const router = express.Router();
router.use(authMiddleware);

// 1. Create Order (Simulated Razorpay Order)
router.post('/create-order', [
  body('amount').isNumeric().withMessage('Amount is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { amount } = req.body;
    const receipt = `RCPT_${Date.now()}`;
    
    // Amount from frontend is in Rs, Razorpay expects paise (Rs * 100)
    const razorpayOrder = await PaymentService.createOrder(amount * 100, receipt);
    
    res.json(razorpayOrder);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Order creation failed' });
  }
});

// 2. Verify Payment & Credit Wallet (Simulated)
router.post('/verify', [
  body('razorpay_order_id').notEmpty(),
  body('razorpay_payment_id').notEmpty(),
  body('razorpay_signature').notEmpty(),
  body('amount').isNumeric(),
], async (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature, amount } = req.body;
    
    const isValid = PaymentService.verifySignature(razorpay_order_id, razorpay_payment_id, razorpay_signature);
    
    if (!isValid) {
      return res.status(400).json({ error: 'Invalid payment signature' });
    }

    // Credit user wallet
    await pool.query(
      'UPDATE balances SET inr_wallet = inr_wallet + $1, updated_at = CURRENT_TIMESTAMP WHERE user_id = $2',
      [amount, req.user.userId]
    );

    // Record transaction
    await pool.query(
      `INSERT INTO transactions (user_id, type, amount, status, reference_id) 
       VALUES ($1, $2, $3, $4, $5)`,
      [req.user.userId, 'deposit', amount, 'completed', razorpay_payment_id]
    );

    res.json({ success: true, message: 'Wallet credited successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Payment verification failed' });
  }
});

module.exports = router;
