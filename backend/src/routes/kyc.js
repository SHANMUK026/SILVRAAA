const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../config/db');
const { authMiddleware } = require('../middleware/auth');
const axios = require('axios');

const router = express.Router();

router.use(authMiddleware);

router.post('/submit', [
  body('aadhar_number').isLength({ min: 12, max: 12 }),
], async (req, res) => {
  try {
    const { aadhar_number } = req.body;
    await pool.query("UPDATE users SET kyc_status = 'pending' WHERE id = $1", [req.user.userId]);
    res.json({ message: 'KYC submitted' });
  } catch (err) {
    res.status(500).json({ error: 'KYC submission failed' });
  }
});

router.get('/status', async (req, res) => {
  try {
    const result = await pool.query('SELECT kyc_status FROM users WHERE id = $1', [req.user.userId]);
    res.json({ status: result.rows[0]?.kyc_status || 'pending' });
  } catch (err) {
    res.status(500).json({ error: 'Failed' });
  }
});

router.post('/initiate', async (req, res) => {
  res.json({ message: 'KYC initiation', redirect_url: null });
});

router.post('/surepass/initiate', async (req, res) => {
  console.log('[KYC LOG] /surepass/initiate received');
  try {
    const response = await axios.post('https://sandbox.surepass.app/api/v1/digilocker/initialize', {
      data: {
        signup_flow: true,
        webhook_url: `${req.protocol}://${req.get('host')}/api/kyc/surepass/callback`
      }
    }, {
      headers: {
        'Authorization': `Bearer ${process.env.SUREPASS_API_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });

    const token = response.data.data.token;
    res.json({
      success: true,
      token: token,
      client_id: response.data.data.client_id,
      url: `https://sandbox.surepass.app/api/v1/digilocker/initialize/${token}`
    });
  } catch (err) {
    console.error('Surepass Init Error:', err.response?.data || err.message);
    // Return a simulation if token is missing for easy testing
    if (!process.env.SUREPASS_API_TOKEN) {
       return res.json({ 
         success: true, 
         token: 'sim_token_123', 
         client_id: 'sim_client_123', 
         url: 'https://surepass.io/simulation/digilocker',
         note: 'Simulation mode' 
       });
    }
    res.status(500).json({ error: 'Failed to initialize KYC' });
  }
});

router.get('/surepass/data/:clientId', async (req, res) => {
  try {
    const { clientId } = req.params;
    const response = await axios.get(`https://sandbox.surepass.app/api/v1/digilocker/download-aadhaar/${clientId}`, {
      headers: {
        'Authorization': `Bearer ${process.env.SUREPASS_API_TOKEN}`
      }
    });
    res.json(response.data);
  } catch (err) {
    console.error('Surepass Data Fetch Error:', err.response?.data || err.message);
    res.status(500).json({ error: 'Failed to fetch KYC data' });
  }
});

router.post('/surepass/callback', async (req, res) => {
  const { client_id, status } = req.body;
  if (status === 'success') {
    // In real scenario, you'd match client_id to a user
    await pool.query("UPDATE users SET kyc_status = 'approved' WHERE id = (SELECT user_id FROM some_record_table WHERE client_id = $1)", [client_id]);
  }
  res.sendStatus(200);
});

module.exports = router;
