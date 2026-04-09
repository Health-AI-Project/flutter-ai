import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Feed')),
      body: const Center(
        child: Text(
          'Feed — MSPR suivante',
          style: TextStyle(color: AppColors.textTertiary),
        ),
      ),
    );
  }
}
