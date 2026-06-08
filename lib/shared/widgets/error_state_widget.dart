import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/utils/error_utils.dart';

class ErrorStateWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final IconData icon;
  final String context;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.icon = Icons.cloud_off_outlined,
    this.context = '',
  });

  @override
  Widget build(BuildContext context) {
    final appError = parseError(error, context: this.context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              appError.userMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            if (onRetry != null && appError.isRetryable) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Réessayer'),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Compact version for inline use (inside cards)
class ErrorCardWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final String context;

  const ErrorCardWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.context = '',
  });

  @override
  Widget build(BuildContext context) {
    final appError = parseError(error, context: this.context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 28, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            appError.userMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          if (onRetry != null && appError.isRetryable) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.refresh, size: 15),
              label: const Text('Réessayer'),
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
