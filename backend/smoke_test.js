const axios = require('axios');

const BASE_URL = 'http://localhost:3001/api';

async function runTests() {
  console.log('--- SILVRA BACKEND SMOKE TESTS ---');

  // 1. Health Check
  try {
    const health = await axios.get(`${BASE_URL}/health`);
    console.log('✓ Health Check:', health.data.status);
  } catch (err) {
    console.error('✗ Health Check Failed:', err.message);
  }

  // 2. Check User (Phone)
  try {
    const checkPhone = await axios.get(`${BASE_URL}/auth/check-phone?phone=8686859588`);
    console.log('✓ Check Phone (8686859588):', checkPhone.data.exists ? 'Found' : 'Not Found');
  } catch (err) {
    console.error('✗ Check Phone Failed:', err.message);
  }

  // 3. Market Prices
  try {
    const prices = await axios.get(`${BASE_URL}/market/prices`);
    console.log('✓ Market Prices:', JSON.stringify(prices.data));
  } catch (err) {
    console.error('✗ Market Prices Failed:', err.message);
  }

  // 4. Test Registration (New User)
  const testEmail = `test_${Date.now()}@example.com`;
  let token = '';
  try {
    const reg = await axios.post(`${BASE_URL}/auth/register`, {
      full_name: 'Test User',
      email: testEmail,
      phone: `99${Math.floor(Math.random() * 100000000)}`,
      password: 'testPassword123'
    });
    console.log('✓ Registration (New): Success');
    token = reg.data.token;
  } catch (err) {
    console.error('✗ Registration Failed:', err.response?.data || err.message);
  }

  // 5. Test Login
  try {
    const login = await axios.post(`${BASE_URL}/auth/login`, {
      email: testEmail,
      password: 'testPassword123'
    });
    console.log('✓ Login (New): Success');
    token = login.data.token;
  } catch (err) {
    console.error('✗ Login Failed:', err.response?.data || err.message);
  }

  // 6. Profile (Authenticated)
  if (token) {
    try {
      const profile = await axios.get(`${BASE_URL}/users/profile`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('✓ Profile Retrieval:', profile.data.full_name);
    } catch (err) {
      console.error('✗ Profile API Failed:', err.response?.data || err.message);
    }

    try {
       const balance = await axios.get(`${BASE_URL}/wallet/balance`, {
          headers: { Authorization: `Bearer ${token}` }
       });
       console.log('✓ Balance Retrieval:', JSON.stringify(balance.data));
    } catch (err) {
       console.error('✗ Balance API Failed:', err.response?.data || err.message);
    }
  }

  console.log('--- TESTS COMPLETE ---');
}

runTests();
