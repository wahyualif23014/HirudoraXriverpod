// lib/features/finance/domain/repositories/finance_repository.dart
import '../../domain/entity/budget_entity.dart';
import '../../domain/entity/transaction_entity.dart';

abstract class FinanceRepository {
  // Budget Operations
  Stream<List<BudgetEntity>> getBudgetsStream();
  Future<void> addBudget(BudgetEntity budget);
  Future<void> updateBudget(BudgetEntity budget);
  Future<void> deleteBudget(String id);
  Future<void> updateBudgetSpent(String budgetId, double amountChange); // Untuk sinkronisasi transaksi

  // Transaction Operations
  Stream<List<TransactionEntity>> getTransactionsStream();
  Future<void> addTransaction(TransactionEntity transaction);
  Future<void> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id, String budgetId, double amount, String transactionType);
}