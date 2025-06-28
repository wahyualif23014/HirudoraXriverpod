// lib/features/finance/data/datasources/finance_remote_datasource.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';


abstract class FinanceRemoteDataSource {
  // Budget
  Stream<List<BudgetModel>> getBudgetsStream();
  Future<void> addBudget(BudgetModel budget);
  Future<void> updateBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
  Future<void> updateBudgetSpent(String budgetId, double amountChange);

  // Transaction
  Stream<List<TransactionModel>> getTransactionsStream();
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id); // Di sini hanya perlu ID untuk delete dari DB
}

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  final FirebaseDatabase _database;
  late final DatabaseReference _budgetsRef;
  late final DatabaseReference _transactionsRef;

  FinanceRemoteDataSourceImpl(this._database) {
    // Sesuaikan path ini dengan struktur database Firebase Anda
    // Disarankan menggunakan UID user untuk memisahkan data per user:
    // _budgetsRef = _database.ref().child('users').child(FirebaseAuth.instance.currentUser!.uid).child('budgets');
    // Untuk saat ini, kita akan menggunakan path generik.
    _budgetsRef = _database.ref().child('budgets');
    _transactionsRef = _database.ref().child('transactions');
  }

  // --- Budget Implementations ---
  @override
  Stream<List<BudgetModel>> getBudgetsStream() {
    return _budgetsRef.onValue.map((event) {
      final List<BudgetModel> budgets = [];
      final dynamic data = event.snapshot.value;

      if (data != null && data is Map) {
        data.forEach((key, value) {
          try {
            final budgetData = Map<String, dynamic>.from(value as Map);
            budgets.add(BudgetModel.fromJson(budgetData, key)); // Kirim key sebagai ID
          } catch (e, st) {
            print('Error parsing budget with key $key: $e\n$st');
          }
        });
      }
      return budgets;
    }).handleError((error, stackTrace) {
      print('Stream Error in getBudgetsStream: $error\n$stackTrace');
      return [];
    });
  }

  @override
  Future<void> addBudget(BudgetModel budget) async {
    try {
      await _budgetsRef.push().set(budget.toJson());
    } on FirebaseException catch (e, st) {
      print('Firebase Error adding budget: ${e.message} (${e.code})\n$st');
      rethrow;
    } catch (e, st) {
      print('Unexpected Error adding budget: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateBudget(BudgetModel budget) async {
    try {
      if (budget.id == null || budget.id!.isEmpty) {
        throw ArgumentError("Budget ID cannot be null or empty for update operation.");
      }
      await _budgetsRef.child(budget.id!).update(budget.toJson());
    } on FirebaseException catch (e, st) {
      print('Firebase Error updating budget ${budget.id}: ${e.message} (${e.code})\n$st');
      rethrow;
    } catch (e, st) {
      print('Unexpected Error updating budget ${budget.id}: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    try {
      await _budgetsRef.child(id).remove();
    } on FirebaseException catch (e, st) {
      print('Firebase Error deleting budget $id: ${e.message} (${e.code})\n$st');
      rethrow;
    } catch (e, st) {
      print('Unexpected Error deleting budget $id: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateBudgetSpent(String budgetId, double amountChange) async {
    try {
      await _budgetsRef.child(budgetId).runTransaction((currentData) {
        final data = Map<String, dynamic>.from(currentData as Map? ?? {});
        double currentSpent = (data['spent'] as num?)?.toDouble() ?? 0.0;
        data['spent'] = currentSpent + amountChange;
        return Transaction.success(data);
      });
    } on FirebaseException catch (e, st) {
      print('Firebase Error updating budget spent for $budgetId: ${e.message} (${e.code})\n$st');
      rethrow;
    } catch (e, st) {
      print('Unexpected Error updating budget spent for $budgetId: $e\n$st');
      rethrow;
    }
  }

  // --- Transaction Implementations ---
  @override
  Stream<List<TransactionModel>> getTransactionsStream() {
    return _transactionsRef.onValue.map((event) {
      final List<TransactionModel> transactions = [];
      final dynamic data = event.snapshot.value;

      if (data != null && data is Map) {
        data.forEach((key, value) {
          try {
            final transactionData = Map<String, dynamic>.from(value as Map);
            transactions.add(TransactionModel.fromJson(transactionData, key));
          } catch (e, st) {
            print('Error parsing transaction with key $key: $e\n$st');
          }
        });
      }
      return transactions;
    }).handleError((error, stackTrace) {
      print('Stream Error in getTransactionsStream: $error\n$stackTrace');
      return [];
    });
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _transactionsRef.push().set(transaction.toJson());
    } on FirebaseException catch (e, st) {
      print('Firebase Error adding transaction: ${e.message} (${e.code})\n$st');
      rethrow;
    } catch (e, st) {
      print('Unexpected Error adding transaction: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      if (transaction.id == null || transaction.id!.isEmpty) {
        throw ArgumentError("Transaction ID cannot be null or empty for update operation.");
      }
      await _transactionsRef.child(transaction.id!).update(transaction.toJson());
    } on FirebaseException catch (e, st) {
      print('Firebase Error updating transaction ${transaction.id}: ${e.message} (${e.code})\n$st');
      rethrow;
    } catch (e, st) {
      print('Unexpected Error updating transaction ${transaction.id}: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsRef.child(id).remove();
    } on FirebaseException catch (e, st) {
      print('Firebase Error deleting transaction $id: ${e.message} (${e.code})\n$st');
      rethrow;
    } catch (e, st) {
      print('Unexpected Error deleting transaction $id: $e\n$st');
      rethrow;
    }
  }
}