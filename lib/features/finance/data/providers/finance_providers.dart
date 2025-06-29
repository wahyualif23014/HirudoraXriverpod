// lib/features/finance/presentation/providers/finance_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import Domain Layer (Entities & Repository Interface)
import '../../domain/entity/budget_entity.dart'; // Sudah benar
import '../../domain/entity/transaction_entity.dart'; // Sudah benar
import '../../data/repositories/finance_repository.dart'; // Sudah benar (interface)

// Import Data Layer (Datasource & Repository Implementation)
import '../../data/datasources/finance_remote_datasource.dart'; // Ini interface FinanceRemoteDataSource
// Anda perlu mengimpor implementasi konkret dari Supabase
import '../../data/datasources/finance_supabase_datasource.dart'; // <--- Perbaikan import
import '../../data/repositories/finance_repository_impl.dart'; // Sudah benar

// Hapus import yang tidak perlu atau duplikat
// import '../datasources/finance_supabase_datasource.dart'; // Hapus ini jika di atas sudah benar
// import '../../../finance/data/datasources/finance_supabase_datasource.dart'; // Hapus ini jika di atas sudah benar

// --- Dependency Providers (Lapisan terbawah, diakses oleh Notifier) ---

// Provider untuk Remote Data Source (implementasi langsung ke Supabase)
// Ini adalah tempat kita menginisialisasi FinanceSupabaseDataSourceImpl
final financeRemoteDataSourceProvider = Provider<FinanceRemoteDataSource>((ref) {
  // Menggunakan Supabase.instance.client yang sudah diinisialisasi di main.dart
  // Pastikan FinanceSupabaseDataSourceImpl diimpor dengan benar di atas
  return FinanceSupabaseDataSourceImpl(Supabase.instance.client);
});

// Provider untuk Repository (implementasi dari interface domain)
// Ini adalah "file" yang memanggil repository yang dimaksud (disediakan untuk Notifier lain).
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final remoteDataSource = ref.read(financeRemoteDataSourceProvider);
  return FinanceRepositoryImpl(remoteDataSource);
});


// --- State Providers (ViewModels untuk UI) ---

// StreamProvider untuk mendapatkan daftar budget secara real-time ke UI
final budgetsStreamProvider = StreamProvider<List<BudgetEntity>>((ref) {
  // Langsung memanggil metode dari Repository
  return ref.read(financeRepositoryProvider).getBudgetsStream();
});

// StreamProvider untuk mendapatkan daftar transaksi secara real-time ke UI
final transactionsStreamProvider = StreamProvider<List<TransactionEntity>>((ref) {
  // Langsung memanggil metode dari Repository
  return ref.read(financeRepositoryProvider).getTransactionsStream();
});


// AsyncNotifierProvider untuk operasi tambah/update/delete budget
// Mengelola state loading/error untuk aksi budget
class BudgetNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Tidak perlu load data di sini untuk operasi CRUD
  }

  Future<void> addBudget(BudgetEntity budget) async {
    state = const AsyncLoading(); // Set state ke loading
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


// AsyncNotifierProvider untuk operasi tambah/update/delete transaksi
class TransactionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addTransaction(TransactionEntity transaction) async {
    state = const AsyncLoading();
    try {
      await ref.read(financeRepositoryProvider).addTransaction(transaction); // Langsung panggil repository

      // --- LOGIKA LINTAS-KEBUTUHAN (CROSS-CUTTING CONCERN) ---
      // Karena tanpa Use Case, logika untuk mengupdate budget spent setelah transaksi
      // DITANGANI DI SINI (di Notifier/ViewModel).
      if (transaction.budgetId.isNotEmpty) {
        // Untuk transaksi 'income', amountChange ke spent adalah negatif (mengurangi spent)
        // Untuk transaksi 'expense', amountChange ke spent adalah positif (menambah spent)
        double amountChange = transaction.type == 'expense' ? transaction.amount : -transaction.amount;
        await ref.read(budgetNotifierProvider.notifier).updateBudgetSpent(
          transaction.budgetId,
          amountChange,
        );
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    state = const AsyncLoading();
    try {

      final oldTransaction = await ref.read(financeRepositoryProvider).getTransactionById(transaction.id);

      // Lakukan update transaksi di database
      await ref.read(financeRepositoryProvider).updateTransaction(transaction); // Ini akan memanggil logic di repo

      // Re-fetch transactions stream untuk memastikan UI up-to-date (optional, karena realtime seharusnya menangani)
      // ref.invalidate(transactionsStreamProvider);
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId, String budgetId, double amount, String transactionType) async {
    state = const AsyncLoading();
    try {
      await ref.read(financeRepositoryProvider).deleteTransaction(transactionId, budgetId, amount, transactionType); // Hapus dari DB dan update budget di repo

      // Setelah repository selesai menghapus dan mengupdate budget, kita bisa set state berhasil
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final transactionNotifierProvider = AsyncNotifierProvider<TransactionNotifier, void>(
  TransactionNotifier.new,
);


// --- Contoh Provider Lain (Tambahan untuk UI) ---

// Provider untuk mendapatkan budget berdasarkan ID
final budgetByIdProvider = Provider.family<BudgetEntity?, String>((ref, id) {
  return ref.watch(budgetsStreamProvider).when(
        data: (budgets) {
          try {
            return budgets.firstWhere((budget) => budget.id == id);
          } catch (_) {
            return null;
          }
        },
        loading: () => null,
        error: (e, st) => null,
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
      // Perhatikan: Stream.value digunakan karena data yang dikembalikan bersifat sync dari data AsyncValue
      return Stream.value({'income': totalIncome, 'expense': totalExpense, 'net': totalIncome - totalExpense});
    },
    loading: () => Stream.value({'income': 0.0, 'expense': 0.0, 'net': 0.0}),
    error: (e, st) => Stream.value({'income': 0.0, 'expense': 0.0, 'net': 0.0}),
  );
});

// Tambahkan provider untuk total balance Supabase
// Ini akan menghitung total balance dari stream transaksi yang sudah ada
final totalBalanceSupabaseProvider = StreamProvider<double>((ref) {
  // Watch transactionsStreamProvider
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
      return Stream.value(totalIncome - totalExpense); // Return a stream with the calculated balance
    },
    loading: () => Stream.value(0.0), // Return a default value when loading
    error: (err, stack) {
      print('Error calculating total balance from transactions stream: $err');
      return Stream.value(0.0); // Return a default value on error
    },
  );
});