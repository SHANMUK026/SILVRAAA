const pool = require('./db');

const initSchema = `
-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  username VARCHAR(100) UNIQUE,
  kyc_status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User addresses
CREATE TABLE IF NOT EXISTS addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  full_name VARCHAR(255),
  address_line_1 VARCHAR(500),
  address_line_2 VARCHAR(500),
  city VARCHAR(100),
  state VARCHAR(100),
  pincode VARCHAR(20),
  phone VARCHAR(20),
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Investment balances
CREATE TABLE IF NOT EXISTS balances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
  gold_grams DECIMAL(18, 6) DEFAULT 0,
  silver_grams DECIMAL(18, 6) DEFAULT 0,
  gold_value_inr DECIMAL(18, 2) DEFAULT 0,
  silver_value_inr DECIMAL(18, 2) DEFAULT 0,
  inr_wallet DECIMAL(18, 2) DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transactions
CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  amount DECIMAL(18, 2) NOT NULL,
  asset_type VARCHAR(20),
  quantity_grams DECIMAL(18, 6),
  status VARCHAR(50) DEFAULT 'pending',
  payment_method VARCHAR(50),
  reference_id VARCHAR(100),
  metadata JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rewards / Aura coins
CREATE TABLE IF NOT EXISTS rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
  aura_coins INTEGER DEFAULT 0,
  tier VARCHAR(50) DEFAULT 'bronze',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- OTP verification (for auth)
CREATE TABLE IF NOT EXISTS otp_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  identifier VARCHAR(255) NOT NULL,
  otp VARCHAR(10) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bank details for withdrawals
CREATE TABLE IF NOT EXISTS bank_details (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
  account_holder_name VARCHAR(255) NOT NULL,
  bank_name VARCHAR(255) NOT NULL,
  account_number VARCHAR(50) NOT NULL,
  ifsc_code VARCHAR(20) NOT NULL,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Withdrawals ledger
CREATE TABLE IF NOT EXISTS withdrawals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  bank_detail_id UUID REFERENCES bank_details(id),
  amount DECIMAL(18, 2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending', -- pending, processed, rejected
  reference_id VARCHAR(100),
  failure_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SIP (Systematic Investment Plan)
CREATE TABLE IF NOT EXISTS sips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  asset_type VARCHAR(20) NOT NULL,
  amount DECIMAL(18, 2) NOT NULL,
  frequency VARCHAR(20) NOT NULL, -- daily, weekly, monthly
  next_run_at TIMESTAMP NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Physical Delivery Orders
CREATE TABLE IF NOT EXISTS delivery_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  address_id UUID REFERENCES addresses(id),
  asset_type VARCHAR(20) NOT NULL, -- gold, silver
  grams DECIMAL(18, 6) NOT NULL,
  making_charges DECIMAL(18, 2) NOT NULL,
  delivery_fee DECIMAL(18, 2) NOT NULL,
  total_payable DECIMAL(18, 2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending', -- pending, packed, shipped, delivered, cancelled
  tracking_id VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Auto-Invest (Buy the Dip) Configurations
CREATE TABLE IF NOT EXISTS auto_invest_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
  asset_type VARCHAR(20) NOT NULL, -- gold, silver
  threshold_percentage DECIMAL(5, 2) NOT NULL, -- e.g. 5.00 for 5% drop
  amount DECIMAL(18, 2) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created ON transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_addresses_user ON addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_withdrawals_user ON withdrawals(user_id);
CREATE INDEX IF NOT EXISTS idx_delivery_user ON delivery_orders(user_id);
`;

async function initDb() {
  try {
    await pool.query(initSchema);
    console.log('Database schema initialized successfully');
  } catch (err) {
    console.error('Database initialization failed:', err);
    throw err;
  }
}

module.exports = { initDb, pool };
