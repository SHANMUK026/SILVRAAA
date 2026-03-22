const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

router.get('/', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM rewards WHERE user_id = $1',
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.json({ aura_coins: 0, tier: 'bronze' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch rewards' });
  }
});

router.post('/spin', async (req, res) => {
  try {
    // TODO: Add daily spin limit, prevent manipulation
    const prizes = [10, 25, 50, 100, 500];
    const won = prizes[Math.floor(Math.random() * prizes.length)];

    await pool.query(
      'UPDATE rewards SET aura_coins = aura_coins + $1, updated_at = CURRENT_TIMESTAMP WHERE user_id = $2',
      [won, req.user.userId]
    );

    res.json({ won, message: `You won ${won} Aura Coins!` });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Spin failed' });
  }
});

router.post('/convert', [
  body('amount_coins').isInt({ min: 100 }),
], async (req, res) => {
  try {
    const { amount_coins } = req.body;
    
    // 1. Check Aura Coins Balance
    const rewardResult = await pool.query('SELECT aura_coins FROM rewards WHERE user_id = $1', [req.user.userId]);
    const currentCoins = rewardResult.rows[0]?.aura_coins || 0;
    
    if (amount_coins > currentCoins) {
      return res.status(400).json({ error: 'Insufficient Aura Coins' });
    }

    // 2. Conversion Rate (Ex: 1000 coins = ₹10)
    const inrValue = amount_coins / 100; // 100 coins = ₹1
    const goldPricePerGram = 6245.5;
    const goldGrams = inrValue / goldPricePerGram;

    await pool.query('BEGIN');

    // 3. Deduct Coins
    await pool.query(
      'UPDATE rewards SET aura_coins = aura_coins - $1, updated_at = CURRENT_TIMESTAMP WHERE user_id = $2',
      [amount_coins, req.user.userId]
    );

    // 4. Add to Gold Balance
    await pool.query(
      `UPDATE balances SET 
       gold_grams = gold_grams + $1,
       gold_value_inr = gold_value_inr + $2,
       updated_at = CURRENT_TIMESTAMP
       WHERE user_id = $3`,
      [goldGrams, inrValue, req.user.userId]
    );

    await pool.query('COMMIT');
    res.json({ message: `Successfully converted ${amount_coins} coins to ${goldGrams.toFixed(6)}g Gold!`, grams: goldGrams });

  } catch (err) {
    await pool.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: 'Conversion failed' });
  }
});

module.exports = router;
