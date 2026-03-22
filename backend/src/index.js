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

// Trust Railway proxy (essential for rate-limiting)
app.set('trust proxy', 1);

app.use(cors({ origin: true, credentials: true }));

// Global error capture for remote debugging
global.lastErrors = [];
function logError(err, context = '') {
  const errorEntry = {
    message: err.message,
    stack: err.stack ? err.stack.substring(0, 200) : 'No stack',
    context: context,
    timestamp: new Date()
  };
  global.lastErrors.unshift(errorEntry);
  if (global.lastErrors.length > 5) global.lastErrors.pop();
  console.error(`[${context}]`, err);
}
global.logError = logError;

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

app.get('/api/health', async (req, res) => {
  try {
    const dbTest = await pool.query('SELECT current_database(), now()');
    const userCount = await pool.query('SELECT COUNT(*) FROM users');
    res.json({ 
      status: 'ok', 
      database: 'connected',
      dbName: dbTest.rows[0].current_database,
      totalUsers: parseInt(userCount.rows[0].count),
      recentErrors: global.lastErrors,
      timestamp: new Date(), 
      uptime: process.uptime() 
    });
  } catch (err) {
    res.status(500).json({ 
      status: 'error', 
      database: 'disconnected', 
      error: err.message,
      timestamp: new Date() 
    });
  }
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
