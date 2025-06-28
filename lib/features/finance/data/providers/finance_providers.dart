// lib/features/finance/presentation/providers/finance_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart'; // Untuk FirebaseDatabase.instance

// Import Domain Layer (Entities & Repository Interface)
import '../../domain/entity/budget_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../../data/repositories/finance_repository.dart';

// Import Data Layer (Datasource & Repository Implementation)
import '../../data/datasources/finance_remote_datasource.dart';
import '../../data/repositories/finance_repository_impl.dart';


// --- Dependency Providers (Lapisan terbawah, diakses oleh Notifier) ---

// Provider untuk Remote Data Source (implementasi langsung ke Firebase)
final financeRemoteDataSourceProvider = Provider<FinanceRemoteDataSource>((ref) {
  // Ini akan mendapatkan instance FirebaseDatabase.instance yang sudah diinisialisasi di main.dart
  return FinanceRemoteDataSourceImpl(FirebaseDatabase.instance);
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
    // Ini dieksekusi saat notifier pertama kali dibuat.
    // Untuk operasi CRUD, state awal biasanya tidak perlu di-load di sini.
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

  // Metode untuk update spent (diakses oleh TransactionNotifier setelah add/delete transaksi)
  Future<void> updateBudgetSpent(String budgetId, double amountChange) async {
    // Note: Metode ini tidak perlu mengatur state AsyncLoading/AsyncData/AsyncError sendiri
    // karena biasanya dipanggil dari dalam Notifier lain yang sudah mengelola state-nya.
    // Ini lebih mirip seperti metode helper di dalam Notifier.
    try {
      await ref.read(financeRepositoryProvider).updateBudgetSpent(budgetId, amountChange);
    } catch (e, st) {
      // Log error, tapi jangan set state dari notifier ini agar tidak mengganggu state utama BudgetNotifier
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
        double amountChange = transaction.type == 'expense' ? transaction.amount : -transaction.amount;
        // Panggil metode updateBudgetSpent dari BudgetNotifier
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
      // Untuk update, jika jumlah atau budgetId transaksi berubah,
      // Anda perlu logika yang lebih kompleks untuk mengupdate budget spent
      // (misal: hitung selisih atau ambil transaksi lama dulu).
      // Ini membutuhkan pemanggilan Repository atau Datasource untuk mendapatkan data lama.
      // Karena kita tidak punya UseCase, logic ini bisa ditaruh di sini
      // atau di Repository jika dianggap bagian dari operasi update transaksional.
      // Untuk kesederhanaan awal, kita hanya update data transaksinya.
      await ref.read(financeRepositoryProvider).updateTransaction(transaction);
      
      // Jika Anda ingin mengupdate spent di budget karena transaksi diupdate:
      // 1. Ambil transaksi LAMA dari database menggunakan ID (jika ada metode di repository/datasource).
      // 2. Hitung 'amountChange' berdasarkan perbedaan antara transaksi lama dan baru.
      // 3. Panggil ref.read(budgetNotifierProvider.notifier).updateBudgetSpent().
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Untuk delete, kita butuh detail transaksi yang dihapus untuk mengembalikan spent ke budget
  Future<void> deleteTransaction(String transactionId, String budgetId, double amount, String transactionType) async {
    state = const AsyncLoading();
    try {
      await ref.read(financeRepositoryProvider).deleteTransaction(transactionId, budgetId, amount, transactionType); // Hapus dari DB

      // --- LOGIKA LINTAS-KEBUTUHAN ---
      // Update spent pada budget terkait setelah transaksi dihapus
      if (budgetId.isNotEmpty) {
        double amountChange = transactionType == 'expense' ? -amount : amount; // Mengembalikan jumlah ke budget
        // Panggil metode updateBudgetSpent dari BudgetNotifier
        await ref.read(budgetNotifierProvider.notifier).updateBudgetSpent(
          budgetId,
          amountChange,
        );
      }
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
// Berguna jika Anda ingin menampilkan detail budget di halaman lain
final budgetByIdProvider = Provider.family<BudgetEntity?, String>((ref, id) {
  // Watch stream budgets, lalu cari yang sesuai ID
  return ref.watch(budgetsStreamProvider).when(
        data: (budgets) {
          try {
            return budgets.firstWhere((budget) => budget.id == id);
          } catch (_) {
            return null;
          }
        },
        loading: () => null, // Sedang loading
        error: (e, st) => null, // Ada error
      );
});

// Provider untuk menghitung ringkasan keuangan (misal: total pengeluaran bulan ini)
// Ini akan mendengarkan stream transaksi dan melakukan kalkulasi.
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
    loading: () => Stream.value({'income': 0.0, 'expense': 0.0, 'net': 0.0}), // Placeholder saat loading
    error: (e, st) => Stream.value({'income': 0.0, 'expense': 0.0, 'net': 0.0}), // Placeholder saat error
  );
});