const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

router.get('/', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM addresses WHERE user_id = $1 ORDER BY is_default DESC, created_at',
      [req.user.userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch addresses' });
  }
});

router.post('/', [
  body('full_name').trim().notEmpty().withMessage('Full name is required'),
  body('address_line_1').trim().notEmpty().withMessage('Address line 1 is required'),
  body('city').trim().notEmpty().withMessage('City is required'),
  body('state').trim().notEmpty().withMessage('State is required'),
  body('pincode').trim().notEmpty().withMessage('Pincode is required'),
  body('phone').trim().notEmpty().withMessage('Phone is required'),
], async (req, res) => {
  const errors = validationResult(req);

  try {

    const { full_name, address_line_1, address_line_2, city, state, pincode, phone, is_default } = req.body;

    if (is_default) {
      await pool.query(
        'UPDATE addresses SET is_default = false WHERE user_id = $1',
        [req.user.userId]
      );
    }

    const result = await pool.query(
      `INSERT INTO addresses (user_id, full_name, address_line_1, address_line_2, city, state, pincode, phone, is_default)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [req.user.userId, full_name, address_line_1, address_line_2 || null, city, state, pincode, phone, is_default || false]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to add address' });
  }
});

router.put('/:id', [
  body('full_name').optional().notEmpty(),
  body('address_line_1').optional().notEmpty(),
  body('city').optional().notEmpty(),
  body('state').optional().notEmpty(),
  body('pincode').optional().notEmpty(),
  body('phone').optional().notEmpty(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id } = req.params;
    const { full_name, address_line_1, address_line_2, city, state, pincode, phone, is_default } = req.body;

    const check = await pool.query(
      'SELECT id FROM addresses WHERE id = $1 AND user_id = $2',
      [id, req.user.userId]
    );

    if (check.rows.length === 0) {
      return res.status(404).json({ error: 'Address not found' });
    }

    const updates = [];
    const values = [];
    let i = 1;

    ['full_name', 'address_line_1', 'address_line_2', 'city', 'state', 'pincode', 'phone'].forEach(field => {
      if (req.body[field] !== undefined) {
        updates.push(`${field} = $${i++}`);
        values.push(req.body[field]);
      }
    });

    if (is_default) {
      await pool.query('UPDATE addresses SET is_default = false WHERE user_id = $1', [req.user.userId]);
      updates.push('is_default = true');
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id);

    await pool.query(
      `UPDATE addresses SET ${updates.join(', ')} WHERE id = $${i}`,
      values
    );

    res.json({ message: 'Address updated' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Update failed' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const result = await pool.query(
      'DELETE FROM addresses WHERE id = $1 AND user_id = $2 RETURNING id',
      [req.params.id, req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Address not found' });
    }

    res.json({ message: 'Address deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Delete failed' });
  }
});

module.exports = router;
