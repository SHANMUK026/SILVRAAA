import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'SILVARA',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Manrope',
            letterSpacing: -1.20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildSlide(
            context,
            titleRich: const TextSpan(
              children: [
                TextSpan(text: 'Faster transfer\n', style: TextStyle(color: Color(0xFFECC813))),
                TextSpan(text: 'of Gold', style: TextStyle(color: Colors.black)),
              ],
            ),
            subtitle: 'Send the money from your\nbank that you want to SILVARA wallet account',
            imageAsset: 'assets/images/slide1.png',
          ),
          _buildSlide(
            context,
            titleRich: const TextSpan(
              children: [
                TextSpan(text: 'Get Physical ', style: TextStyle(color: Colors.black)),
                TextSpan(text: 'GOLD\n', style: TextStyle(color: Color(0xFFECC813))),
                TextSpan(text: 'delivery in minutes', style: TextStyle(color: Colors.black)),
              ],
            ),
            subtitle: 'Send the money from your\ninternet bank that you want to\nswitch to the ekambiá account',
            imageAsset: 'assets/images/slide2.png',
            isGreyBackground: true,
          ),
          _buildSlide(
            context,
            titleRich: const TextSpan(
              children: [
                TextSpan(text: 'The peak of\n', style: TextStyle(color: Colors.black)),
                TextSpan(text: 'Transparency', style: TextStyle(color: Color(0xFFECC813))),
              ],
            ),
            subtitle: 'Send the money from your internet\nbank that you want to switch to the\nekambiá account',
            imageAsset: 'assets/images/slide3.png',
            isGreyBackground: true,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: _currentPage == 0 ? Colors.white : const Color(0xFFF6F6F6),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    width: 168,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD709),
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33FFD709),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                          spreadRadius: -3,
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Color(0xFF5B4B00),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(BuildContext context, {required TextSpan titleRich, required String subtitle, required String imageAsset, bool isGreyBackground = false}) {
    return Container(
      width: double.infinity,
      color: isGreyBackground ? const Color(0xFFF6F6F6) : Colors.white,
      child: Column(
        children: [
          // Graphic Area - using Flexible to prevent overflow
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft background radial glow
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFD709).withValues(alpha: 0.15),
                        const Color(0xFFFFD709).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                // 3D Image from Assets
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imageAsset),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Text Content Area
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text.rich(
                    titleRich,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -0.90,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF5A5C5C),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Page Indicators
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? const Color(0xFFFFD709) : const Color(0xFFDBDDDD),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
