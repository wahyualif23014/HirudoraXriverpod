// Contoh: lib/features/finance/presentation/pages/finance_overview_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinanceOverviewPage extends ConsumerWidget {
  const FinanceOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finance Overview')),
      body: const Center(child: Text('Halaman Finance Overview')),
    );
  }
}