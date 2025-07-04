// lib/finance/data/datasources/finance_remote_datasource.dart

// Tambahkan import Supabase
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../models/budget_model.dart';
import '../models/transaction_model.dart'; 

abstract class FinanceRemoteDataSource {
  // Budget
  Stream<List<BudgetModel>> getBudgetsStream();
  Future<void> addBudget(BudgetModel budget);
  Future<void> updateBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
  Future<void> updateBudgetSpent(String budgetId, double amountChange);
  Future<BudgetModel?> getBudgetById(String id);

  // Transaction
  Stream<List<TransactionModel>> getTransactionsStream();
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id); 
  Future<TransactionModel?> getTransactionById(String id); 
}

class FinanceSupabaseDataSourceImpl implements FinanceRemoteDataSource { 
  final SupabaseClient _supabase;

  FinanceSupabaseDataSourceImpl(this._supabase);

  // --- Budget Implementations ---
  @override
  Stream<List<BudgetModel>> getBudgetsStream() {
    return _supabase
        .from('budgets') 
        .stream(primaryKey: ['id']) 
        .map((List<Map<String, dynamic>> maps) {
          return maps.map((map) => BudgetModel.fromJson(map)).toList();
        }).handleError((error, stackTrace) {
          print('Supabase Stream Error in getBudgetsStream: $error\n$stackTrace');
          throw Exception('Failed to load budgets stream: $error');
        });
  }

  @override
  Future<void> addBudget(BudgetModel budget) async {
    try {
      await _supabase.from('budgets').insert(budget.toJson());
    } on PostgrestException catch (e, st) {
      print('Supabase Error adding budget: ${e.message} (Code: ${e.code})\n$st');
      throw Exception('Failed to add budget: ${e.message}');
    } catch (e, st) {
      print('Unexpected Error adding budget: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateBudget(BudgetModel budget) async {
    try {
      if (budget.id.isEmpty) { 
        throw ArgumentError("Budget ID cannot be empty for update operation.");
      }
      await _supabase.from('budgets').update(budget.toJson()).eq('id', budget.id);
    } on PostgrestException catch (e, st) {
      print('Supabase Error updating budget ${budget.id}: ${e.message} (Code: ${e.code})\n$st');
      throw Exception('Failed to update budget: ${e.message}');
    } catch (e, st) {
      print('Unexpected Error updating budget ${budget.id}: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    try {
      await _supabase.from('budgets').delete().eq('id', id);
    } on PostgrestException catch (e, st) {
      print('Supabase Error deleting budget $id: ${e.message} (Code: ${e.code})\n$st');
      throw Exception('Failed to delete budget: ${e.message}');
    } catch (e, st) {
      print('Unexpected Error deleting budget $id: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateBudgetSpent(String budgetId, double amountChange) async {
    try {

      
      final response = await _supabase.from('budgets').select('spent_amount').eq('id', budgetId).single();

      if (response.isNotEmpty) {
        double currentSpent = (response['spent_amount'] as num).toDouble();
        double newSpent = currentSpent + amountChange;

        await _supabase.from('budgets').update({'spent_amount': newSpent}).eq('id', budgetId);
      } else {
        throw Exception('Budget with ID $budgetId not found for spent update.');
      }
    } on PostgrestException catch (e, st) {
      print('Supabase Error updating budget spent for $budgetId: ${e.message} (Code: ${e.code})\n$st');
      throw Exception('Failed to update budget spent: ${e.message}');
    } catch (e, st) {
      print('Unexpected Error updating budget spent for $budgetId: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<BudgetModel?> getBudgetById(String id) async {
    try {
      final response = await _supabase.from('budgets').select().eq('id', id).single();
      if (response.isNotEmpty) {
        return BudgetModel.fromJson(response);
      }
      return null;
    } on PostgrestException catch (e, st) {
      print('Supabase Error getting budget by ID $id: ${e.message} (Code: ${e.code})\n$st');
      return null;
    } catch (e, st) {
      print('Unexpected Error getting budget by ID $id: $e\n$st');
      rethrow; 
    }
  }

  // --- Transaction Implementations ---
  @override
  Stream<List<TransactionModel>> getTransactionsStream() {
    return _supabase
        .from('transactions') 
        .stream(primaryKey: ['id'])
        .map((List<Map<String, dynamic>> maps) {
          return maps.map((map) => TransactionModel.fromJson(map)).toList();
        }).handleError((error, stackTrace) {
          print('Supabase Stream Error in getTransactionsStream: $error\n$stackTrace');
          throw Exception('Failed to load transactions stream: $error');
        });
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _supabase.from('transactions').insert(transaction.toJson());
    } on PostgrestException catch (e, st) {
      print('Supabase Error adding transaction: ${e.message} (Code: ${e.code})\n$st');
      throw Exception('Failed to add transaction: ${e.message}');
    } catch (e, st) {
      print('Unexpected Error adding transaction: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      if (transaction.id.isEmpty) {
        throw ArgumentError("Transaction ID cannot be empty for update operation.");
      }
      await _supabase.from('transactions').update(transaction.toJson()).eq('id', transaction.id);
    } on PostgrestException catch (e, st) {
      print('Supabase Error updating transaction ${transaction.id}: ${e.message} (Code: ${e.code})\n$st');
      throw Exception('Failed to update transaction: ${e.message}');
    } catch (e, st) {
      print('Unexpected Error updating transaction ${transaction.id}: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _supabase.from('transactions').delete().eq('id', id);
    } on PostgrestException catch (e, st) {
      print('Supabase Error deleting transaction $id: ${e.message} (Code: ${e.code})\n$st');
      throw Exception('Failed to delete transaction: ${e.message}');
    } catch (e, st) {
      print('Unexpected Error deleting transaction $id: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final response = await _supabase.from('transactions').select().eq('id', id).single();
      if (response.isNotEmpty) {
        return TransactionModel.fromJson(response);
      }
      return null;
    } on PostgrestException catch (e, st) {
      print('Supabase Error getting transaction by ID $id: ${e.message} (Code: ${e.code})\n$st');
      return null;
    } catch (e, st) {
      print('Unexpected Error getting transaction by ID $id: $e\n$st');
      rethrow;
    }
  }
}