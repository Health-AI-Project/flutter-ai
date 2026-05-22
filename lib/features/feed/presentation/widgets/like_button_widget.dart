import 'package:flutter/material.dart';
import '../../../../../app/theme.dart';

class LikeButton extends StatefulWidget {
  final int count;
  final bool liked;
  final VoidCallback onTap;

  const LikeButton({
    super.key,
    required this.count,
    required this.liked,
    required this.onTap,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1, end: 1.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Icon(
                widget.liked ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: widget.liked ? const Color(0xFFE05252) : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.count}',
              style: TextStyle(
                fontSize: 13,
                color: widget.liked ? const Color(0xFFE05252) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
