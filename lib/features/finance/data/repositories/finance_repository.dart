// lib/finance/data/repositories/finance_repository.dart
import '../../domain/entity/budget_entity.dart';
import '../../domain/entity/transaction_entity.dart';

abstract class FinanceRepository {
  // Budget Operations
  Future<void> addBudget(BudgetEntity budget);
  Future<void> updateBudget(BudgetEntity budget);
  Future<void> deleteBudget(String id);
  Stream<List<BudgetEntity>> getBudgetsStream();
  Future<void> updateBudgetSpent(String budgetId, double amountChange);
  Future<BudgetEntity?> getBudgetById(String id);

  // Transaction Operations
  Future<void> addTransaction(TransactionEntity transaction);
  Future<void> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String transactionId, String budgetId, double amount, String transactionType); 
  Stream<List<TransactionEntity>> getTransactionsStream();
  Future<TransactionEntity?> getTransactionById(String id);
}