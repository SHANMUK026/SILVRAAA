import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import all screens
import '../screens/splash_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/kyc_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/dashboard/portfolio_screen.dart';
import '../screens/dashboard/history_screen.dart';
import '../screens/dashboard/wallet_screen.dart';
import '../screens/dashboard/profile_screen.dart';
import '../screens/dashboard/main_wrapper.dart';
import '../screens/market/buy_screen.dart';
import '../screens/market/sell_screen.dart';
import '../screens/market/withdraw_screen.dart';
import '../screens/market/delivery_screen.dart';
import '../screens/utilities/calculator_screen.dart';
import '../screens/utilities/saving_plans_screen.dart';
import '../screens/utilities/rewards_screen.dart';
import '../screens/market/market_screen.dart';
import '../screens/market/wealth_calculator_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (state.uri.path == '/markets') return '/market';
      return null;
    },
    routes: [
      // Entry & Setup
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Auth Flow
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phoneNumber = state.extra; // Support String or Map
          return OtpScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: '/kyc',
        builder: (context, state) => const KycScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main Dashboard (With Bottom Nav Wrapper)
      ShellRoute(
        builder: (context, state, child) => MainWrapper(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/portfolio',
            builder: (context, state) => const PortfolioScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/wealth',
            builder: (context, state) => const PortfolioScreen(),
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: '/rewards',
            builder: (context, state) => const RewardsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Market Screens (Now Outside Shell)
      GoRoute(
        path: '/market',
        builder: (context, state) => const MarketScreen(),
      ),

      // Market Actions
      GoRoute(
        path: '/buy',
        builder: (context, state) {
          bool isGold = true;
          if (state.extra is bool) {
            isGold = state.extra as bool;
          } else if (state.extra is Map) {
            final map = state.extra as Map<String, dynamic>;
            isGold = map['isGold'] ?? true;
          }
          return BuyScreen(isGold: isGold);
        },
      ),
      GoRoute(
        path: '/sell',
        builder: (context, state) => const SellScreen(),
      ),
      GoRoute(
        path: '/withdraw',
        builder: (context, state) => const WithdrawScreen(),
      ),
      GoRoute(
        path: '/delivery',
        builder: (context, state) => const DeliveryScreen(),
      ),

      // Utilities
      GoRoute(
        path: '/calculator',
        builder: (context, state) => const WealthCalculatorScreen(),
      ),
      GoRoute(
        path: '/savings',
        builder: (context, state) => const SavingPlansScreen(),
      ),
    ],
  );
}
