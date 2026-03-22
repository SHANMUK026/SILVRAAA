require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { initDb, pool } = require('./config/initDb');
const { apiLimiter, securityMiddleware } = require('./middleware/security');

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const investmentRoutes = require('./routes/investments');
const rewardsRoutes = require('./routes/rewards');
const deliveryRoutes = require('./routes/delivery');
const paymentRoutes = require('./routes/payments');
const marketRoutes = require('./routes/market');
const addressRoutes = require('./routes/addresses');
const kycRoutes = require('./routes/kyc');
const walletRoutes = require('./routes/wallet');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors({ origin: true, credentials: true }));
app.use(express.json());
app.use((req, res, next) => {
  console.log(`[ROUTE LOG] ${req.method} ${req.originalUrl}`);
  next();
});
app.use(securityMiddleware());
app.use('/api', apiLimiter);

app.post('/api/auth/debug/approve-kyc', async (req, res) => {
  const { phone } = req.body;
  await pool.query("UPDATE users SET kyc_status = 'approved' WHERE phone = $1", [phone]);
  res.json({ message: 'KYC Approved' });
});

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/investments', investmentRoutes);
app.use('/api/rewards', rewardsRoutes);
app.use('/api/delivery', deliveryRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/market', marketRoutes);
app.use('/api/addresses', addressRoutes);
app.use('/api/kyc', kycRoutes);
app.use('/api/wallet', walletRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date(), uptime: process.uptime() });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date(), uptime: process.uptime() });
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

async function start() {
  try {
    await initDb();
    console.log('Database connected ✓');
  } catch (err) {
    console.warn('Database init failed (check credentials in .env):', err.message);
    console.warn('API will start but database operations will fail.');
  }
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`\nSILVARA API running on http://localhost:${PORT}`);
    console.log(`Health: http://localhost:${PORT}/api/health\n`);
  });
}

start();
