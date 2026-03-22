/**
 * Payment Service Simulator.
 * Mirrors the Razorpay Node.js SDK patterns.
 */
class PaymentService {
  /**
   * Creates a simulated Razorpay Order.
   * @param {number} amount - Amount in INR (integer, e.g. 100 for Rs 1).
   * @param {string} receipt - Unique receipt ID.
   */
  static async createOrder(amount, receipt) {
    // Simulator for razorpay.orders.create()
    console.log(`\n[Razorpay Simulator] Creating Order: Rs ${amount/100}`);
    
    return {
      id: `order_${Math.random().toString(36).substr(2, 9)}`,
      entity: 'order',
      amount: amount,
      currency: 'INR',
      receipt: receipt,
      status: 'created',
      created_at: Math.floor(Date.now() / 1000)
    };
  }

  /**
   * Verifies the payment signature (Simulated).
   */
  static verifySignature(orderId, paymentId, signature) {
    // In real Razorpay: uses hmac sha256
    // Simulator: always returns true if data is present
    return orderId && paymentId && signature;
  }
}

module.exports = PaymentService;
