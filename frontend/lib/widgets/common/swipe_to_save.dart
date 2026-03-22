import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class SwipeToSave extends StatefulWidget {
  final double amount;
  final VoidCallback onSwipeCompleted;

  const SwipeToSave({
    super.key,
    required this.amount,
    required this.onSwipeCompleted,
  });

  @override
  State<SwipeToSave> createState() => _SwipeToSaveState();
}

class _SwipeToSaveState extends State<SwipeToSave> {
  double _dragValue = 0.0;
  final double _knobSize = 52.0;
  final double _trackHeight = 60.0;
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag = constraints.maxWidth - _knobSize - 8;
        
        return Container(
          width: double.infinity,
          height: _trackHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
          ),
          child: Stack(
            children: [
              // Sliding text
              Center(
                child: Opacity(
                  opacity: (1 - (_dragValue / maxDrag)).clamp(0.0, 1.0),
                  child: Text(
                    'Slide to Invest ₹${widget.amount.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFFBEBEBE),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.32,
                    ),
                  ),
                ),
              ),
              
              // The Handle
              Positioned(
                left: 4 + _dragValue,
                top: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isCompleted) return;
                    setState(() {
                      _dragValue += details.delta.dx;
                      _dragValue = _dragValue.clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isCompleted) return;
                    if (_dragValue > maxDrag * 0.8) {
                      setState(() {
                        _dragValue = maxDrag;
                        _isCompleted = true;
                      });
                      widget.onSwipeCompleted();
                      
                      // Auto-reset after 3 seconds so user can save again
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) {
                          setState(() {
                            _dragValue = 0.0;
                            _isCompleted = false;
                          });
                        }
                      });
                    } else {
                      setState(() {
                        _dragValue = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: _knobSize,
                    height: _knobSize,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                  ),
                ),
              ),
              
              // End lock icon (matching Figma)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
                  ),
                  child: Icon(
                    _isCompleted ? Icons.check : Icons.lock_outline,
                    color: _isCompleted ? AppColors.success : const Color(0xFFE5E7EB),
                    size: 20,
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
