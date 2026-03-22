const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const pool = require('../config/db');
const SmsService = require('../utils/smsService');
const { authLimiter } = require('../middleware/security');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-in-production';

router.use(authLimiter);

router.get('/check-phone', async (req, res) => {
  try {
    const { phone } = req.query;
    if (!phone) return res.status(400).json({ error: 'Phone number required' });
    
    const result = await pool.query('SELECT id FROM users WHERE phone = $1', [phone]);
    res.json({ exists: result.rows.length > 0 });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Check failed' });
  }
});

router.get('/check-email', async (req, res) => {
  try {
    const { email } = req.query;
    if (!email) return res.status(400).json({ error: 'Email required' });
    
    const result = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    res.json({ exists: result.rows.length > 0 });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Check failed' });
  }
});

router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
  body('full_name').optional().trim(),
  body('phone').optional().trim(),
], async (req, res) => {
  console.log('[AUTH LOG] Register attempt:', req.body.email, req.body.phone);
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password, full_name, phone } = req.body;
    const passwordHash = await bcrypt.hash(password, 12);

    const result = await pool.query(
      `INSERT INTO users (email, password_hash, full_name, phone, username) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING id, email, full_name, username, created_at`,
      [email, passwordHash, full_name || null, phone || null, email.split('@')[0]]
    );

    const user = result.rows[0];
    await pool.query(
      'INSERT INTO balances (user_id) VALUES ($1)',
      [user.id]
    );
    await pool.query(
      'INSERT INTO rewards (user_id) VALUES ($1)',
      [user.id]
    );

    const token = jwt.sign(
      { userId: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      user: { id: user.id, email: user.email, full_name: user.full_name, username: user.username },
      token,
      expiresIn: 604800,
    });
  } catch (err) {
    if (err.code === '23505') {
      return res.status(400).json({ error: 'Email already registered' });
    }
    console.error(err);
    res.status(500).json({ error: 'Registration failed' });
  }
});

router.post('/login', [
  body('email').optional().isEmail().normalizeEmail(),
  body('phone').optional().trim(),
  body('password').notEmpty(),
], async (req, res) => {
  try {
    const { email, phone, password } = req.body;
    
    if (!email && !phone) {
      return res.status(400).json({ error: 'Email or Phone required' });
    }

    let user;
    if (email) {
      const result = await pool.query('SELECT id, email, phone, password_hash, full_name, username FROM users WHERE email = $1', [email]);
      user = result.rows[0];
    } else {
      const result = await pool.query('SELECT id, email, phone, password_hash, full_name, username FROM users WHERE phone = $1', [phone]);
      user = result.rows[0];
    }

    if (!user) {
      // User doesn't exist popup requirement
      return res.status(404).json({ error: "User doesn't exist, please signup" });
    }

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      // Wrong password popup requirement
      return res.status(401).json({ error: 'Incorrect credentials' });
    }

    const token = jwt.sign(
      { userId: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      user: { id: user.id, email: user.email, phone: user.phone, full_name: user.full_name, username: user.username },
      token,
      expiresIn: 604800,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Login failed' });
  }
});

// --- Forgot Password Flow ---

router.post('/forgot-password/send-otp', async (req, res) => {
  try {
    const { phone } = req.body;
    if (!phone) return res.status(400).json({ error: 'Phone number required' });

    // Check if user exists
    const userResult = await pool.query('SELECT id FROM users WHERE phone = $1', [phone]);
    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'No account found with this phone number' });
    }

    const otp = process.env.NODE_ENV === 'development' ? '123456' : Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 mins

    await pool.query(
      'INSERT INTO otp_verifications (identifier, otp, expires_at) VALUES ($1, $2, $3)',
      [phone, otp, expiresAt]
    );

    if (process.env.NODE_ENV === 'development') {
      await SmsService.sendOTP(phone, otp);
    }

    res.json({ message: 'OTP sent successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to send OTP' });
  }
});

router.post('/forgot-password/verify-otp', async (req, res) => {
  try {
    const { phone, otp } = req.body;
    const result = await pool.query(
      'SELECT id FROM otp_verifications WHERE identifier = $1 AND otp = $2 AND expires_at > NOW() AND verified = false ORDER BY created_at DESC LIMIT 1',
      [phone, otp]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid or expired OTP' });
    }

    await pool.query('UPDATE otp_verifications SET verified = true WHERE id = $1', [result.rows[0].id]);
    
    // Generate a temporary reset token
    const resetToken = jwt.sign({ phone, type: 'password_reset' }, JWT_SECRET, { expiresIn: '15m' });

    res.json({ message: 'OTP verified', resetToken });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Verification failed' });
  }
});

router.post('/forgot-password/reset', async (req, res) => {
  try {
    const { resetToken, newPassword } = req.body;
    const decoded = jwt.verify(resetToken, JWT_SECRET);
    
    if (decoded.type !== 'password_reset') {
      return res.status(403).json({ error: 'Invalid reset token' });
    }

    const hashed = await bcrypt.hash(newPassword, 12);
    await pool.query('UPDATE users SET password_hash = $1 WHERE phone = $2', [hashed, decoded.phone]);

    res.json({ message: 'Password updated successfully' });
  } catch (err) {
    console.error(err);
    res.status(401).json({ error: 'Reset token expired or invalid' });
  }
});

router.post('/send-otp', [
  body('identifier').notEmpty().withMessage('Email or phone required'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { identifier } = req.body;
    const otp = process.env.NODE_ENV === 'development' ? '123456' : Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await pool.query(
      'INSERT INTO otp_verifications (identifier, otp, expires_at) VALUES ($1, $2, $3)',
      [identifier, otp, expiresAt]
    );

    // TODO: Integrate with real OTP API (MSG91, Twilio, etc.)
    if (process.env.NODE_ENV === 'development') {
      await SmsService.sendOTP(identifier, otp);
    }

    res.json({ message: 'OTP sent successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to send OTP' });
  }
});

router.post('/verify-otp', [
  body('identifier').notEmpty(),
  body('otp').isLength({ min: 6, max: 6 }),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { identifier, otp } = req.body;

    const result = await pool.query(
      `SELECT id FROM otp_verifications 
       WHERE identifier = $1 AND otp = $2 AND expires_at > NOW() AND verified = false`,
      [identifier, otp]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid or expired OTP' });
    }

    await pool.query(
      'UPDATE otp_verifications SET verified = true WHERE id = $1',
      [result.rows[0].id]
    );

    res.json({ message: 'OTP verified successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Verification failed' });
  }
});

module.exports = router;
