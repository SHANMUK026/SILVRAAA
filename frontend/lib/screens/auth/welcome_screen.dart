import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine screen scale (for vertical ratio)
    final double h = MediaQuery.of(context).size.height;
    
    // Scale factor compared to original Figma 796 height
    final double scale = h / 796.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Top Decorative Section Gradient
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: Container(
              height: h * 0.50, // Approx 356/796 
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.02, 0.98),
                  end: Alignment(1.02, 0.02),
                  colors: [
                    Color(0xFFFAF5FF), 
                    Colors.white, 
                    Color(0xFFECFDF5)
                  ],
                ),
              ),
            ),
          ),
          
          // 2. Art Elements (Using roughly scaled positions matching Figma)
          // Top Left Circle
          Positioned(
            left: 32,
            top: 48 * scale,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF35), width: 5),
              ),
            ),
          ),

          // Bottom Left Cutoff Circle
          Positioned(
            left: -24,
            top: 220.33 * scale,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFECB613), width: 5),
              ),
            ),
          ),

          // Top Right Black Pill
          Positioned(
            right: 38,
            top: 36.85 * scale,
            child: Transform.rotate(
              angle: 0.21,
              child: Container(
                width: 32,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),

          // Center Pill Outline with Shadow and Icon
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 80 * scale),
              child: Container(
                width: 96,
                height: 192,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: const Color(0xFFECC813), width: 5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 50,
                      offset: Offset(0, 25),
                      spreadRadius: -12,
                    )
                  ],
                ),
                child: const Center(
                  // Star/Hand placeholder for the Vector Node
                  child: Icon(
                    Icons.touch_app_outlined, 
                    color: Color(0xFFECC813), 
                    size: 48,
                  ),
                ),
              ),
            ),
          ),

          // 3. Text & Interactables Container
          Positioned(
            left: 40,
            right: 40,
            bottom: 40, // Base padding
            top: h * 0.48, // Start below the main pill area
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titles
                Text.rich(
                  const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF0F172A),
                      fontSize: 36,
                      height: 1.15,
                      letterSpacing: -0.90,
                    ),
                    children: [
                      TextSpan(
                        text: 'Easy ways to\n',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: 'manage your\n',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: 'finances ✨',
                        style: TextStyle(fontWeight: FontWeight.w400, fontFamily: 'Noto Color Emoji'), // Emoji fallback
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14.88),
                
                // Subtitle
                const Text(
                  'Smart tools to track, save and grow\nyour wealth in one place.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    height: 1.63,
                  ),
                ),
                const Spacer(),

                // 4. Swipe To Get Started Button
                SwipeToStartButton(
                  onSwipeCompleted: () {
                    // Route to the 3-page Onboarding slides
                    context.go('/onboarding');
                  },
                ),
                const SizedBox(height: 32),

                // 5. Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECC813),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Exactly formatted Custom Swipe Logic
class SwipeToStartButton extends StatefulWidget {
  final VoidCallback onSwipeCompleted;

  const SwipeToStartButton({super.key, required this.onSwipeCompleted});

  @override
  State<SwipeToStartButton> createState() => _SwipeToStartButtonState();
}

class _SwipeToStartButtonState extends State<SwipeToStartButton> {
  double _dragPosition = 0.0;
  bool _isCompleted = false;
  final double _knobSize = 48.0; 
  final double _padding = 8.0; 

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag = constraints.maxWidth - _knobSize - (_padding * 2);

        return Container(
          width: double.infinity,
          height: 64, // Exact Figma height
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 30,
                offset: Offset(0, 10),
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // 1. Text properly centered
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 32.0),
                  child: Text(
                    'Swipe To Get Started',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                      height: 1.43,
                    ),
                  ),
                ),
              ),
              
              // 2. Exact Slider Knob Configuration
              Positioned(
                left: _padding + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isCompleted) return;
                    setState(() {
                      _dragPosition += details.delta.dx;
                      if (_dragPosition < 0) _dragPosition = 0;
                      if (_dragPosition >= maxDrag) {
                        _dragPosition = maxDrag;
                        _isCompleted = true;
                        widget.onSwipeCompleted();
                      }
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (!_isCompleted) {
                      setState(() {
                        _dragPosition = 0.0; // Snap back
                      });
                    }
                  },
                  child: Container(
                    width: _knobSize,
                    height: _knobSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECB613),
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 15,
                          offset: Offset(0, 10),
                          spreadRadius: -3,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.keyboard_double_arrow_right,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
