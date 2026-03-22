import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.53.24.253:3001/api', // Local IP for physical mobile testing
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  )..interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        print('--- DIO LOG: $obj');
      },
    ));

  static void printBaseUrl() {
    print('--- CURRENT BASE URL: ${_dio.options.baseUrl}');
  }

  // Helper to add Auth token to headers
  static Future<void> _addAuthHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Market Data
  static Future<Map<String, dynamic>> fetchMarketPrices() async {
    try {
      final response = await _dio.get('/market/prices');
      return response.data;
    } catch (e) {
      return {'gold': 6500.0, 'silver': 85.0}; // Fallback
    }
  }

  static Future<bool> checkEmailExists(String email) async {
    try {
      final response = await _dio.get('/auth/check-email', queryParameters: {'email': email});
      return response.data['exists'] ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkPhoneExists(String phone) async {
    try {
      final response = await _dio.get('/auth/check-phone', queryParameters: {'phone': phone});
      return response.data['exists'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'full_name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Registration failed'};
    }
  }

  // Login (Handles specific errors like "User doesn't exist")
  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final data = identifier.contains('@') ? {'email': identifier, 'password': password} : {'phone': identifier, 'password': password};
      final response = await _dio.post('/auth/login', data: data);
      
      if (response.data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response.data['token']);
      }
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Login failed'};
    }
  }

  // Forgot Password
  static Future<Map<String, dynamic>> sendForgotPasswordOtp(String phone) async {
    try {
      final response = await _dio.post('/auth/forgot-password/send-otp', data: {'phone': phone});
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Failed to send OTP'};
    }
  }

  static Future<Map<String, dynamic>> verifyForgotPasswordOtp(String phone, String otp) async {
    try {
      final response = await _dio.post('/auth/forgot-password/verify-otp', data: {'phone': phone, 'otp': otp});
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'OTP verification failed'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String resetToken, String newPassword) async {
    try {
      final response = await _dio.post('/auth/forgot-password/reset', data: {
        'resetToken': resetToken,
        'newPassword': newPassword,
      });
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Password reset failed'};
    }
  }

  // KYC
  static Future<Map<String, dynamic>> submitKyc(String aadhar, {String? pan}) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/kyc/submit', data: {
        'aadhar_number': aadhar,
        'pan_number': pan,
      });
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'KYC submission failed'};
    }
  }

  static Future<String> checkKycStatus() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('/kyc/status');
      return response.data['status'] ?? 'pending';
    } catch (e) {
      return 'pending';
    }
  }

  // Surepass DigiLocker
  static Future<Map<String, dynamic>> initiateSurepassKyc() async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/kyc/surepass/initiate');
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Failed to start DigiLocker flow'};
    }
  }

  // Investments
  static Future<Map<String, dynamic>> invest({
    required double amount,
    required String assetType,
    String? paymentMethod,
  }) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/investments/invest', data: {
        'amount': amount,
        'asset_type': assetType,
        'payment_method': paymentMethod ?? 'upi',
      });
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Investment failed'};
    }
  }

  // SIP & Investments
  static Future<Map<String, dynamic>> setupSip({
    required String assetType,
    required double amount,
    required String frequency,
  }) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/investments/sip', data: {
        'asset_type': assetType,
        'amount': amount,
        'frequency': frequency,
      });
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Failed to setup SIP'};
    }
  }

  static Future<Map<String, dynamic>> setupAutoInvest({
    required String assetType,
    required double amount,
    required double threshold,
  }) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/investments/auto-invest', data: {
        'asset_type': assetType,
        'amount': amount,
        'threshold_percentage': threshold,
      });
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Failed to setup Auto-Invest'};
    }
  }

  static Future<List<dynamic>> fetchTransactions() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('/investments/transactions');
      return response.data;
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> fetchSips() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('/investments/sips');
      return response.data;
    } catch (e) {
      return [];
    }
  }

  // Rewards
  static Future<Map<String, dynamic>> fetchRewards() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('/rewards');
      return response.data;
    } catch (e) {
      return {'aura_coins': 1250, 'tier': 'Gold Member'};
    }
  }

  static Future<Map<String, dynamic>> convertRewards(int amountCoins) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/rewards/convert', data: {'amount_coins': amountCoins});
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Conversion failed'};
    }
  }

  // Delivery
  static Future<List<dynamic>> fetchAddresses() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('/delivery/addresses');
      return response.data;
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> placeDeliveryOrder({
    required String addressId,
    required String assetType,
    required double grams,
    required double makingCharges,
    required double deliveryFee,
  }) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/delivery/order', data: {
        'address_id': addressId,
        'asset_type': assetType,
        'grams': grams,
        'making_charges': makingCharges,
        'delivery_fee': deliveryFee,
      });
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Order failed'};
    }
  }

  // Wallet & Balance
  static Future<Map<String, dynamic>> fetchBalance() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('/wallet/balance');
      return response.data;
    } catch (e) {
      return {'inr_wallet': 0.0, 'gold_grams': 0.0, 'silver_grams': 0.0};
    }
  }

  static Future<Map<String, dynamic>> fetchProfile() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('/users/profile');
      return response.data;
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> fetchBankDetails() async {
    try {
      await _addAuthHeader();
      final response = await _dio.get('/wallet/bank');
      return response.data;
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> linkBank(Map<String, dynamic> details) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/wallet/bank', data: details);
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Linking failed'};
    }
  }

  static Future<Map<String, dynamic>> initiateWithdrawal(double amount) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/wallet/withdraw', data: {'amount': amount});
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Withdrawal failed'};
    }
  }

  // Payments / Deposits
  static Future<Map<String, dynamic>> createPaymentOrder(double amount) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/payments/create-order', data: {'amount': amount});
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Order creation failed'};
    }
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required double amount,
  }) async {
    try {
      await _addAuthHeader();
      final response = await _dio.post('/payments/verify', data: {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
        'amount': amount,
      });
      return response.data;
    } on DioException catch (e) {
      return {'error': e.response?.data['error'] ?? 'Verification failed'};
    }
  }
}
