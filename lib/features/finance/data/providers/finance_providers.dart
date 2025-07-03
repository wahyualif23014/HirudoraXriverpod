// lib/features/finance/presentation/providers/finance_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entity/budget_entity.dart'; 
import '../../domain/entity/transaction_entity.dart';
import '../../data/repositories/finance_repository.dart';

import '../../data/datasources/finance_remote_datasource.dart'; 
import '../../data/repositories/finance_repository_impl.dart'; 



final financeRemoteDataSourceProvider = Provider<FinanceRemoteDataSource>((ref) {
  return FinanceSupabaseDataSourceImpl(Supabase.instance.client);
});

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final remoteDataSource = ref.read(financeRemoteDataSourceProvider);
  return FinanceRepositoryImpl(remoteDataSource);
});


// --- State Providers (ViewModels untuk UI) ---

final budgetsStreamProvider = StreamProvider<List<BudgetEntity>>((ref) {
  // Langsung memanggil method dari Repository
  return ref.read(financeRepositoryProvider).getBudgetsStream();
});

final transactionsStreamProvider = StreamProvider<List<TransactionEntity>>((ref) {
  // Langsung memanggil method dari Repository
  return ref.read(financeRepositoryProvider).getTransactionsStream();
});


class BudgetNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
  }

  Future<void> addBudget(BudgetEntity budget) async {
    state = const AsyncLoading(); 
    try {
      await ref.read(financeRepositoryProvider).addBudget(budget);
      state = const AsyncData(null); 
    } catch (e, st) {
      state = AsyncError(e, st); 
      rethrow; 
    }
  }

  Future<void> updateBudget(BudgetEntity budget) async {
    state = const AsyncLoading();
    try {
      await ref.read(financeRepositoryProvider).updateBudget(budget); 
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteBudget(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(financeRepositoryProvider).deleteBudget(id); 
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
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    state = const AsyncLoading();
    try {
      await ref.read(financeRepositoryProvider).addTransaction(transaction);
      state = const AsyncData(null); 
    } catch (e, st) {
      state = AsyncError(e, st); 
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    state = const AsyncLoading(); 
    try {
      await ref.read(financeRepositoryProvider).updateTransaction(transaction);
      state = const AsyncData(null); 
    } catch (e, st) {
      state = AsyncError(e, st); 
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId, String budgetId, double amount, String transactionType) async {
    state = const AsyncLoading(); 
    try {
      await ref.read(financeRepositoryProvider).deleteTransaction(transactionId, budgetId, amount, transactionType);
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



// Provider untuk mendapatkan budget berdasarkan ID
final budgetByIdProvider = Provider.family<BudgetEntity?, String>((ref, id) {
  final budgetsAsyncValue = ref.watch(budgetsStreamProvider);

  return budgetsAsyncValue.when(
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
