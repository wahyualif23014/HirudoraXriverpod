// lib/finance/data/datasources/finance_supabase_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceSupabaseDataSource {
  final SupabaseClient _supabase;

  FinanceSupabaseDataSource(this._supabase);

  // Method untuk mendapatkan total saldo dari semua transaksi
  // Asumsi: Kita menjumlahkan semua 'income' dan mengurangi 'expense'
  Future<double> getTotalBalance() async {
    try {
      // Mengambil semua transaksi dari tabel 'transactions'
      // Untuk sementara, kita ambil semua karena belum ada filter user_id
      final List<Map<String, dynamic>> transactions = await _supabase
          .from('transactions')
          .select('amount, type'); // Hanya ambil kolom yang relevan

      double totalIncome = 0.0;
      double totalExpense = 0.0;

      for (var transaction in transactions) {
        final amount = (transaction['amount'] as num).toDouble();
        final type = transaction['type'] as String;

        if (type == 'income') {
          totalIncome += amount;
        } else if (type == 'expense') {
          totalExpense += amount;
        }
      }
      return totalIncome - totalExpense;
    } catch (e) {
      print('Error fetching total balance from Supabase: $e');
      // Penting: Melemparkan exception agar Riverpod bisa menangkapnya
      throw Exception('Failed to fetch total balance: $e');
    }
  }

  // Method untuk menambah transaksi baru
  Future<void> addTransaction({
    required double amount,
    required String type, // Misalnya 'income' atau 'expense'
    String? description,
  }) async {
    try {
      await _supabase.from('transactions').insert({
        'amount': amount,
        'type': type,
        'description': description,
        // user_id tidak disertakan karena kita belum menggunakan autentikasi
      });
      print('Transaction added successfully to Supabase!');
    } catch (e) {
      print('Error adding transaction to Supabase: $e');
      throw Exception('Failed to add transaction: $e');
    }
  }
  
  // Anda bisa menambahkan method lain seperti getTransactions(), updateTransaction(), deleteTransaction()
}