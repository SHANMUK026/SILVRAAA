const axios = require('axios');

const BASE_URL = 'http://localhost:3001/api';
const testData = {
  phone: '9998887770',
  email: 'investor@silvra.in',
  password: 'SecurePassword123!',
  name: 'Trial Investor'
};

let token = '';

async function runFullFlow() {
  console.log('--- SILVRA FULL FLOW VERIFICATION (INVESTOR JOURNEY) ---');

  try {
    // 1. Initial State
    console.log('\n[1] Checking if user exists...');
    const exists = await axios.get(`${BASE_URL}/auth/check-phone?phone=${testData.phone}`);
    console.log('User status:', exists.data);

    if (!exists.data.exists) {
      // 2. Register
      console.log('\n[2] Registering new user...');
      const regRes = await axios.post(`${BASE_URL}/auth/register`, {
        full_name: testData.name,
        email: testData.email,
        phone: testData.phone,
        password: testData.password
      });
      console.log('✓ Registered. User ID:', regRes.data.user.id);
    }

    // 3. Login
    console.log('\n[3] Logging in...');
    const loginRes = await axios.post(`${BASE_URL}/auth/login`, {
      phone: testData.phone,
      password: testData.password
    });
    token = loginRes.data.token;
    console.log('✓ Login successful. Token received.');

    // 3.5 Force Approve KYC (to allow Sell/Withdraw/Delivery)
    console.log('\n[3.5] Force Approving KYC for testing...');
    await axios.post(`${BASE_URL}/kyc/initiate`, {}, { headers: { Authorization: `Bearer ${token}` } }); // just to satisfy flow
    // Directly update DB via a special debug endpoint or just assume we have one.
    // In this repo, I'll add a temporary debug endpoint to index.js to approve KYC for a user.
    await axios.post(`${BASE_URL}/auth/debug/approve-kyc`, { phone: testData.phone });
    console.log('✓ KYC Approved.');

    const headers = { Authorization: `Bearer ${token}` };

    // 4. Fetch Market Prices
    console.log('\n[4] Fetching Live Market Prices...');
    const priceRes = await axios.get(`${BASE_URL}/market/prices`);
    console.log('✓ Prices:', priceRes.data);

    // 5. Test Simulated Payment (Add Rs 5000)
    console.log('\n[5] Simulating Payment (Deposit ₹5000)...');
    const orderRes = await axios.post(`${BASE_URL}/payments/create-order`, { amount: 5000 }, { headers });
    const orderId = orderRes.data.id;
    console.log('✓ Order Created:', orderId);

    const verifyRes = await axios.post(`${BASE_URL}/payments/verify`, {
      razorpay_order_id: orderId,
      razorpay_payment_id: 'pay_simulated_123',
      razorpay_signature: 'sig_simulated_456',
      amount: 5000
    }, { headers });
    console.log('✓ Payment Verified:', verifyRes.data.message);

    // 6. Check Balance
    console.log('\n[6] Verifying Balance Update...');
    const balRes = await axios.get(`${BASE_URL}/wallet/balance`, { headers });
    console.log('✓ Current Balance:', balRes.data);

    // 7. Invest in Gold (using real-time price)
    console.log('\n[7] Investing ₹1000 in Gold...');
    const invRes = await axios.post(`${BASE_URL}/investments/invest`, {
      amount: 1000,
      asset_type: 'gold'
    }, { headers });
    console.log('✓ Investment Success. Bought:', invRes.data.quantity_grams, 'grams');

    // 8. Sell Gold
    console.log('\n[8] Selling 0.01g Gold...');
    const sellRes = await axios.post(`${BASE_URL}/investments/sell`, {
      asset_type: 'gold',
      quantity_grams: 0.01
    }, { headers });
    console.log('✓ Sell Success. Received: ₹', sellRes.data.payout_amount);

    // 9. Physical Delivery Request
    console.log('\n[9] Requesting Physical Delivery (1g Gold)...');
    // First need an address
    const addrRes = await axios.post(`${BASE_URL}/addresses`, {
      full_name: 'Trial User',
      address_line_1: '123 Multi-Storey Bldg',
      city: 'Mumbai',
      state: 'Maharashtra',
      pincode: '400001',
      phone: '9000000001',
      is_default: true
    }, { headers });
    const addressId = addrRes.data.id;

    const delivRes = await axios.post(`${BASE_URL}/delivery/order`, {
      address_id: addressId,
      asset_type: 'gold',
      grams: 0.05,
      making_charges: 200,
      delivery_fee: 150
    }, { headers });
    console.log('✓ Delivery Order Placed:', delivRes.data.order_id);

    // 10. Withdraw to Bank
    console.log('\n[10] Withdrawing ₹500 to Bank...');
    // Need bank link
    await axios.post(`${BASE_URL}/wallet/bank`, {
      account_holder_name: 'Trial User',
      bank_name: 'HDFC Bank',
      account_number: '1234567890',
      ifsc_code: 'HDFC0001234'
    }, { headers });

    const withRes = await axios.post(`${BASE_URL}/wallet/withdraw`, {
      amount: 500
    }, { headers });
    console.log('✓ Withdrawal Requested:', withRes.data.withdrawal_id);

    // 11. Rewards Conversion
    console.log('\n[11] Spinning for Aura Coins...');
    await axios.post(`${BASE_URL}/rewards/spin`, {}, { headers });
    
    console.log('Converting Aura Coins to Gold...');
    const rewRes = await axios.post(`${BASE_URL}/rewards/convert`, {
      amount_coins: 10
    }, { headers });
    console.log('✓ Reward Conversion Success:', rewRes.data.message);

    console.log('\n--- ALL SCENARIOS VERIFIED SUCCESSFULLY ---');
    console.log('1. Registration/Login: OK');
    console.log('2. Market Prices: OK');
    console.log('3. Payments/Deposit: OK');
    console.log('4. Buy/Sell Assets: OK');
    console.log('5. Physical Delivery: OK');
    console.log('6. Bank/Withdrawal: OK');
    console.log('7. Rewards/Loyalty: OK');

  } catch (error) {
    console.error('X Flow Failed:', error.response?.data || error.message);
  }
}

runFullFlow();
