import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/offline_provider.dart';
import '../widgets/day_card_widget.dart';
import '../widgets/sync_status_widget.dart';

class WeekPlanScreen extends ConsumerStatefulWidget {
  const WeekPlanScreen({super.key});

  @override
  ConsumerState<WeekPlanScreen> createState() => _WeekPlanScreenState();
}

class _WeekPlanScreenState extends ConsumerState<WeekPlanScreen> {
  static const _userId = 'test-user-001';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(weekPlanNotifierProvider.notifier).loadPlan(_userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(weekPlanNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Planning de la semaine')),
      body: planState.when(
        data: (plan) {
          if (plan == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              SyncStatusWidget(
                isFromCache: plan.isFromCache,
                syncedAt: plan.syncedAt,
                onRefresh: () => ref
                    .read(weekPlanNotifierProvider.notifier)
                    .forceSync(_userId),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: plan.days.length,
                  itemBuilder: (context, index) =>
                      DayCardWidget(dayPlan: plan.days[index]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                  onPressed: () => ref
                      .read(weekPlanNotifierProvider.notifier)
                      .loadPlan(_userId),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.sync),
        label: const Text('Synchroniser'),
        onPressed: () =>
            ref.read(weekPlanNotifierProvider.notifier).forceSync(_userId),
      ),
    );
  }
}
