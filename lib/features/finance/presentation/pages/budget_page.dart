// lib/features/finance/presentation/pages/budget_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Saya'),
        backgroundColor: Colors.blueAccent, // Contoh warna AppBar
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Anggaran',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Anggaran Bulan Ini:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Total Anggaran: Rp 5.000.000',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Text(
                      'Sisa Anggaran: Rp 2.500.000',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                    const SizedBox(height: 15),
                    LinearProgressIndicator(
                      value: 0.5, // Contoh: 50% anggaran terpakai
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '50% Terpakai',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Kategori Anggaran',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: const [
                  BudgetCategoryItem(category: 'Makanan', allocated: 1500000, spent: 1200000),
                  BudgetCategoryItem(category: 'Transportasi', allocated: 500000, spent: 300000),
                  BudgetCategoryItem(category: 'Hiburan', allocated: 700000, spent: 750000), // Melebihi anggaran
                  BudgetCategoryItem(category: 'Pendidikan', allocated: 1000000, spent: 400000),
                  BudgetCategoryItem(category: 'Lain-lain', allocated: 1300000, spent: 0),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi untuk menambah atau mengelola anggaran
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tombol "Kelola Anggaran" ditekan!')),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

// Widget terpisah untuk menampilkan item kategori anggaran
class BudgetCategoryItem extends StatelessWidget {
  final String category;
  final int allocated;
  final int spent;

  const BudgetCategoryItem({
    super.key,
    required this.category,
    required this.allocated,
    required this.spent,
  });

  @override
  Widget build(BuildContext context) {
    final double percentageSpent = allocated > 0 ? spent / allocated : 0.0;
    final Color progressColor = percentageSpent > 1.0 ? Colors.red : Colors.blue;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dialokasikan: Rp ${allocated.toStringAsFixed(0)}'),
                Text('Terpakai: Rp ${spent.toStringAsFixed(0)}',
                    style: TextStyle(color: percentageSpent > 1.0 ? Colors.red : Colors.black)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentageSpent.clamp(0.0, 1.0), // Pastikan nilai antara 0 dan 1
              backgroundColor: Colors.grey[200],
              color: progressColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 5),
            Text(
              '${(percentageSpent * 100).toStringAsFixed(0)}% Terpakai',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}