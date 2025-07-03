// lib/finance/data/repositories/finance_repository_impl.dart
import '../datasources/finance_remote_datasource.dart';
import '../../domain/entity/budget_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../repositories/finance_repository.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart'; 

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;

  FinanceRepositoryImpl(this.remoteDataSource);

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
  Stream<List<BudgetEntity>> getBudgetsStream() {
    return remoteDataSource.getBudgetsStream().map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> updateBudgetSpent(String budgetId, double amountChange) {
    return remoteDataSource.updateBudgetSpent(budgetId, amountChange);
  }

  @override
  Future<BudgetEntity?> getBudgetById(String id) async {
    final budgetModel = await remoteDataSource.getBudgetById(id);
    return budgetModel?.toEntity(); 
  }

@override
  Future<void> addTransaction(TransactionEntity transaction) async {
    await remoteDataSource.addTransaction(TransactionModel.fromEntity(transaction));

    // Logika update budget spent untuk addTransaction sekarang di repository
    if (transaction.budgetId != null && transaction.budgetId!.isNotEmpty) {
      double amountChange = transaction.type == 'expense' ? transaction.amount : -transaction.amount;
      await remoteDataSource.updateBudgetSpent(transaction.budgetId!, amountChange);
    }
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    final oldTransactionModel = await remoteDataSource.getTransactionById(transaction.id);
    if (oldTransactionModel == null) {
      throw Exception('Original transaction not found for update.');
    }
    final oldTransaction = oldTransactionModel.toEntity();

    await remoteDataSource.updateTransaction(TransactionModel.fromEntity(transaction));

    // --- Logika Penyesuaian Budget Saat Update Transaksi ---
    if (oldTransaction.budgetId != null && oldTransaction.budgetId!.isNotEmpty) {
      if (oldTransaction.budgetId != transaction.budgetId) {
        // Batalkan efek transaksi lama pada budget lama
        double oldAmountChange = oldTransaction.type == 'expense' ? -oldTransaction.amount : oldTransaction.amount;
        await remoteDataSource.updateBudgetSpent(oldTransaction.budgetId!, oldAmountChange);
      } else if (oldTransaction.amount != transaction.amount || oldTransaction.type != transaction.type) {
        // Kasus 2: amount atau type berubah pada budget yang SAMA
        double oldEffect = oldTransaction.type == 'expense' ? oldTransaction.amount : -oldTransaction.amount;
        double newEffect = transaction.type == 'expense' ? transaction.amount : -transaction.amount;
        double changeForOldBudget = newEffect - oldEffect;
        await remoteDataSource.updateBudgetSpent(oldTransaction.budgetId!, changeForOldBudget);
      }
    }

    // Kasus 3: Transaksi baru dikaitkan dengan budget atau budgetId-nya berbeda dari sebelumnya
    if (transaction.budgetId != null && transaction.budgetId!.isNotEmpty && oldTransaction.budgetId != transaction.budgetId) {
      double newAmountChange = transaction.type == 'expense' ? transaction.amount : -transaction.amount;
      await remoteDataSource.updateBudgetSpent(transaction.budgetId!, newAmountChange);
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId, String budgetId, double amount, String transactionType) async {
    await remoteDataSource.deleteTransaction(transactionId);
    if (budgetId.isNotEmpty) {
      double amountChange = transactionType == 'expense' ? -amount : amount;
      await remoteDataSource.updateBudgetSpent(budgetId, amountChange);
    }
  }

  @override
  Stream<List<TransactionEntity>> getTransactionsStream() {
    return remoteDataSource.getTransactionsStream().map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    final transactionModel = await remoteDataSource.getTransactionById(id);
    return transactionModel?.toEntity();
  }
}