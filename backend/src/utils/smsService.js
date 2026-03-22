/**
 * SMS Service Simulator.
 * Architected to be exactly like the Airtel IQ / DLT API flow.
 */
class SmsService {
  /**
   * Sends an OTP or transactional SMS.
   * @param {string} phone - Recipient phone number.
   * @param {string} message - Message content.
   * @param {string} templateId - DLT Approved Template ID.
   */
  static async send(phone, message, templateId = 'DEFAULT_TPL') {
    // SIMULATOR: In production, substitute with Airtel IQ POST request.
    console.log('\n--- SMS SIMULATOR (Airtel DLT) ---');
    console.log(`To: +91${phone}`);
    console.log(`Template ID: ${templateId}`);
    console.log(`Message: ${message}`);
    console.log('--- SENT SUCCESSFULLY ---\n');

    return { success: true, message_id: `MSG_${Date.now()}` };
  }

  static async sendOTP(phone, otp) {
    const message = `Welcome to SILVRA! Your verification code is ${otp}. Please do not share this with anyone.`;
    const templateId = 'OTP_VERIFY_01'; // Example DLT ID
    return this.send(phone, message, templateId);
  }
}

module.exports = SmsService;
