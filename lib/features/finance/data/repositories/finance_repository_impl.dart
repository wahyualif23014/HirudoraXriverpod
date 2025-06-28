// lib/features/finance/data/repositories/finance_repository_impl.dart
import '../../../finance/domain/entity/budget_entity.dart';
import '../../../finance/domain/entity/transaction_entity.dart';
import '../../../finance/data/repositories/finance_repository.dart';
import '../datasources/finance_remote_datasource.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;

  FinanceRepositoryImpl(this.remoteDataSource);

  // --- Budget Implementations ---
  @override
  Stream<List<BudgetEntity>> getBudgetsStream() {
    return remoteDataSource.getBudgetsStream(); // Datasource sudah mengembalikan List<BudgetModel> yang merupakan List<BudgetEntity>
  }

  @override
  Future<void> addBudget(BudgetEntity budget) {
    return remoteDataSource.addBudget(BudgetModel.fromEntity(budget));
  }

  @override
  Future<void> updateBudget(BudgetEntity budget) {
    return remoteDataSource.updateBudget(BudgetModel.fromEntity(budget));
  }

  @override
  Future<void> deleteBudget(String id) {
    return remoteDataSource.deleteBudget(id);
  }

  @override
  Future<void> updateBudgetSpent(String budgetId, double amountChange) {
    return remoteDataSource.updateBudgetSpent(budgetId, amountChange);
  }

  // --- Transaction Implementations ---
  @override
  Stream<List<TransactionEntity>> getTransactionsStream() {
    return remoteDataSource.getTransactionsStream(); // Datasource sudah mengembalikan List<TransactionModel> yang merupakan List<TransactionEntity>
  }

  @override
  Future<void> addTransaction(TransactionEntity transaction) {
    return remoteDataSource.addTransaction(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) {
    return remoteDataSource.updateTransaction(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<void> deleteTransaction(String id, String budgetId, double amount, String transactionType) {
    // Note: Parameter budgetId, amount, transactionType di sini digunakan di Notifier,
    // tapi repository sendiri hanya perlu ID transaksi untuk menghapus dari DB.
    return remoteDataSource.deleteTransaction(id);
  }
}