const express = require('express');
const PriceService = require('../services/priceService');
const router = express.Router();

// GET /api/market/prices
router.get('/prices', async (req, res) => {
  try {
    const prices = await PriceService.getLatestPrices();
    res.json(prices);
  } catch (err) {
    console.error('Market Price Error:', err);
    res.status(500).json({ error: 'Failed to fetch market data' });
  }
});

module.exports = router;
