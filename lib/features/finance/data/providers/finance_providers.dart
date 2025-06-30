// lib/features/finance/presentation/providers/finance_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import Domain Layer (Entities & Repository Interface)
import '../../domain/entity/budget_entity.dart'; // Sudah benar
import '../../domain/entity/transaction_entity.dart'; // Sudah benar
import '../../data/repositories/finance_repository.dart'; // Sudah benar (interface)

import '../../data/datasources/finance_remote_datasource.dart'; 
import '../../data/repositories/finance_repository_impl.dart'; // Sudah benar

// --- Dependency Providers (Lapisan terbawah, diakses oleh Notifier) ---

// Provider untuk Remote Data Source (implementasi langsung ke Supabase)
// Ini adalah tempat kita menginisialisasi FinanceSupabaseDataSourceImpl
final financeRemoteDataSourceProvider = Provider<FinanceRemoteDataSource>((ref) {
  return FinanceSupabaseDataSourceImpl(Supabase.instance.client);
});

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final remoteDataSource = ref.read(financeRemoteDataSourceProvider);
  return FinanceRepositoryImpl(remoteDataSource);
});


// --- State Providers (ViewModels untuk UI) ---

final budgetsStreamProvider = StreamProvider<List<BudgetEntity>>((ref) {
  // Langsung memanggil metode dari Repository
  return ref.read(financeRepositoryProvider).getBudgetsStream();
});

// StreamProvider untuk mendapatkan daftar transaksi secara real-time ke UI
final transactionsStreamProvider = StreamProvider<List<TransactionEntity>>((ref) {
  // Langsung memanggil metode dari Repository
  return ref.read(financeRepositoryProvider).getTransactionsStream();
});


class BudgetNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
  }

  Future<void> addBudget(BudgetEntity budget) async {
    state = const AsyncLoading(); 
    try {
      await ref.read(financeRepositoryProvider).addBudget(budget); // Langsung panggil repository
      state = const AsyncData(null); // Set state ke data (berhasil)
    } catch (e, st) {
      state = AsyncError(e, st); // Set state ke error
      rethrow; // Lempar kembali error agar bisa ditangkap di UI untuk Snackbar, dll.
    }
  }

  Future<void> updateBudget(BudgetEntity budget) async {
    state = const AsyncLoading();
    try {
      await ref.read(financeRepositoryProvider).updateBudget(budget); // Langsung panggil repository
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteBudget(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(financeRepositoryProvider).deleteBudget(id); // Langsung panggil repository
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateBudgetSpent(String budgetId, double amountChange) async {
    try {
      await ref.read(financeRepositoryProvider).updateBudgetSpent(budgetId, amountChange);
    } catch (e, st) {
      print('Error updating budget spent from BudgetNotifier: $e\n$st');
      rethrow;
    }
  }
}

final budgetNotifierProvider = AsyncNotifierProvider<BudgetNotifier, void>(
  BudgetNotifier.new,
);

// / AsyncNotifierProvider untuk operasi tambah/update/delete transaksi
class TransactionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Tidak ada state awal yang perlu dibangun secara asinkron untuk notifier ini
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    state = const AsyncLoading(); // Set state loading
    try {
      // Panggil repository. Logika update budget SPENT harus sudah ada di dalam repository.
      await ref.read(financeRepositoryProvider).addTransaction(transaction);
      state = const AsyncData(null); // Set state sukses
    } catch (e, st) {
      state = AsyncError(e, st); // Set state error
      rethrow; // Lempar kembali error agar bisa ditangkap di UI jika diperlukan
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    state = const AsyncLoading(); // Set state loading
    try {
      // Panggil repository. Logika update budget SPENT harus sudah ada di dalam repository.
      await ref.read(financeRepositoryProvider).updateTransaction(transaction);
      state = const AsyncData(null); // Set state sukses
    } catch (e, st) {
      state = AsyncError(e, st); // Set state error
      rethrow; // Lempar kembali error
    }
  }

  Future<void> deleteTransaction(String transactionId, String budgetId, double amount, String transactionType) async {
    state = const AsyncLoading(); // Set state loading
    try {
      // Panggil repository. Logika update budget SPENT harus sudah ada di dalam repository.
      await ref.read(financeRepositoryProvider).deleteTransaction(transactionId, budgetId, amount, transactionType);
      state = const AsyncData(null); // Set state sukses
    } catch (e, st) {
      state = AsyncError(e, st); // Set state error
      rethrow; // Lempar kembali error
    }
  }
}

final transactionNotifierProvider = AsyncNotifierProvider<TransactionNotifier, void>(
  TransactionNotifier.new,
);


// --- Provider-provider Lain (Tidak berubah, sudah benar) ---

// Provider untuk mendapatkan budget berdasarkan ID
final budgetByIdProvider = Provider.family<BudgetEntity?, String>((ref, id) {
  // Watch budgetsStreamProvider untuk mendapatkan daftar budget
  final budgetsAsyncValue = ref.watch(budgetsStreamProvider);

  // Gunakan .when() untuk mengekstrak data dari AsyncValue
  return budgetsAsyncValue.when(
    data: (budgets) {
      // Ketika data tersedia, coba cari budget berdasarkan ID
      try {
        return budgets.firstWhere((budget) => budget.id == id);
      } catch (_) {
        // Jika tidak ditemukan, kembalikan null
        return null;
      }
    },
    // Saat loading atau error, kembalikan null atau nilai default yang sesuai
    loading: () => null, // Saat loading, kita tidak punya budget, jadi null
    error: (e, st) => null, // Saat error, kita tidak punya budget, jadi null
  );
});

// Provider untuk menghitung ringkasan keuangan (misal: total pengeluaran bulan ini)
final monthlyFinanceSummaryProvider = StreamProvider.family<Map<String, double>, DateTime>((ref, monthYear) {
  return ref.watch(transactionsStreamProvider).when(
    data: (transactions) {
      double totalIncome = 0;
      double totalExpense = 0;

      for (var tr in transactions) {
        if (tr.date.year == monthYear.year && tr.date.month == monthYear.month) {
          if (tr.type == 'income') {
            totalIncome += tr.amount;
          } else if (tr.type == 'expense') {
            totalExpense += tr.amount;
          }
        }
      }
      return Stream.value({'income': totalIncome, 'expense': totalExpense, 'net': totalIncome - totalExpense});
    },
    loading: () => Stream.value({'income': 0.0, 'expense': 0.0, 'net': 0.0}),
    error: (e, st) => Stream.value({'income': 0.0, 'expense': 0.0, 'net': 0.0}),
  );
});

// Tambahkan provider untuk total balance Supabase
final totalBalanceSupabaseProvider = StreamProvider<double>((ref) {
  return ref.watch(transactionsStreamProvider).when(
    data: (transactions) {
      double totalIncome = 0.0;
      double totalExpense = 0.0;
      for (var tr in transactions) {
        if (tr.type == 'income') {
          totalIncome += tr.amount;
        } else if (tr.type == 'expense') {
          totalExpense += tr.amount;
        }
      }
      return Stream.value(totalIncome - totalExpense);
    },
    loading: () => Stream.value(0.0),
    error: (err, stack) {
      print('Error calculating total balance from transactions stream: $err');
      return Stream.value(0.0);
    },
  );
});
