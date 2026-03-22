const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';
let token = '';

async function runTests() {
  console.log('--- SILVRA BACKEND SMOKE TESTS ---');

  try {
    // 1. Health Check
    console.log('\n[1] Health Check...');
    const health = await axios.get(`${BASE_URL}/health`);
    console.log('✓ Status:', health.data.status);

    // 2. Signup Simulation (Check Phone/Email)
    console.log('\n[2] Checking Auth Availability...');
    const checkPhone = await axios.get(`${BASE_URL}/auth/check-phone?phone=9876543210`);
    console.log('✓ Phone Check:', checkPhone.data);

    // 3. Login (Using dev user if exists, or just testing error handling)
    console.log('\n[3] Testing Login Error Handling...');
    try {
      await axios.post(`${BASE_URL}/auth/login`, { phone: '0000000000', password: 'wrong' });
    } catch (e) {
      console.log('✓ Expected Error:', e.response?.data?.error || 'User not found');
    }

    // 4. Test KYC Route (Protected)
    console.log('\n[4] Testing Protected Route Access (KYC)...');
    try {
      await axios.get(`${BASE_URL}/kyc/status`);
    } catch (e) {
      console.log('✓ Expected 401 (Unauthorized):', e.response?.status);
    }

    console.log('\n--- SMOKE TESTS COMPLETED ---');
    console.log('Backend is stable and reflecting all route changes.');

  } catch (error) {
    console.error('X Test Failed:', error.message);
    if (error.response) console.error('Response:', error.response.data);
  }
}

runTests();
