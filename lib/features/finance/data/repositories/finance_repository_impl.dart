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
    // Konversi Entity ke Model sebelum dikirim ke datasource
    return remoteDataSource.addBudget(BudgetModel.fromEntity(budget));
  }

  @override
  Future<void> updateBudget(BudgetEntity budget) {
    // Konversi Entity ke Model sebelum dikirim ke datasource
    return remoteDataSource.updateBudget(BudgetModel.fromEntity(budget));
  }

  @override
  Future<void> deleteBudget(String id) {
    return remoteDataSource.deleteBudget(id);
  }

  @override
  Stream<List<BudgetEntity>> getBudgetsStream() {
    // DataSource sekarang mengembalikan Stream<List<BudgetModel>>.
    // Kita perlu memetakan (map) setiap BudgetModel di dalam stream menjadi BudgetEntity.
    return remoteDataSource.getBudgetsStream().map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> updateBudgetSpent(String budgetId, double amountChange) {
    return remoteDataSource.updateBudgetSpent(budgetId, amountChange);
  }

  @override
  // Implementasi getBudgetById dari interface FinanceRepository
  Future<BudgetEntity?> getBudgetById(String id) async {
    final budgetModel = await remoteDataSource.getBudgetById(id);
    return budgetModel?.toEntity(); // Konversi BudgetModel ke BudgetEntity
  }


  @override
  Future<void> addTransaction(TransactionEntity transaction) {
    // Konversi Entity ke Model sebelum dikirim ke datasource
    return remoteDataSource.addTransaction(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    // 1. Ambil transaksi lama (dalam bentuk Model dari DataSource)
    final oldTransactionModel = await remoteDataSource.getTransactionById(transaction.id);
    if (oldTransactionModel == null) {
      throw Exception('Original transaction not found for update.');
    }
    // Konversi model lama ke entity agar logika bisnis di repository tetap bekerja dengan entity
    final oldTransaction = oldTransactionModel.toEntity();


    // 2. Lakukan update transaksi di database (kirim dalam bentuk Model)
    await remoteDataSource.updateTransaction(TransactionModel.fromEntity(transaction));

    // 3. Update budget lama jika budgetId berubah atau amount/type berubah
    if (oldTransaction.budgetId.isNotEmpty) {
      if (oldTransaction.budgetId != transaction.budgetId) {
        // Kasus: budgetId berubah (transaksi dipindahkan ke budget lain atau dihapus dari budget lama)
        // Mengembalikan jumlah lama ke budget lama
        double oldAmountChange = oldTransaction.type == 'expense' ? -oldTransaction.amount : oldTransaction.amount; // Membatalkan efek
        await remoteDataSource.updateBudgetSpent(oldTransaction.budgetId, oldAmountChange);
      } else if (oldTransaction.amount != transaction.amount || oldTransaction.type != transaction.type) {
        // Kasus: budgetId sama tapi jumlah atau tipe transaksi berubah
        double oldEffect = oldTransaction.type == 'expense' ? oldTransaction.amount : -oldTransaction.amount;
        double newEffect = transaction.type == 'expense' ? transaction.amount : -transaction.amount;
        double changeForOldBudget = newEffect - oldEffect; // Hitung selisih perubahan
        await remoteDataSource.updateBudgetSpent(oldTransaction.budgetId, changeForOldBudget);
      }
    }


    // 4. Update budget baru jika budgetId baru tidak kosong DAN berbeda dari yang lama
    if (transaction.budgetId.isNotEmpty && oldTransaction.budgetId != transaction.budgetId) {
      // Jika budgetId baru ada dan berbeda dari yang lama, tambahkan ke budget baru
      double newAmountChange = transaction.type == 'expense' ? transaction.amount : -transaction.amount; // Efek ke budget baru
      await remoteDataSource.updateBudgetSpent(transaction.budgetId, newAmountChange);
    }
  }


  @override
  Future<void> deleteTransaction(String transactionId, String budgetId, double amount, String transactionType) async {
    // 1. Hapus transaksi dari database
    await remoteDataSource.deleteTransaction(transactionId);

    // 2. Update budget spent jika transaksi yang dihapus terkait dengan budget
    if (budgetId.isNotEmpty) {
      // Kembalikan jumlah ke budget (jika expense, kurangi spent; jika income, tambah spent)
      double amountChange = transactionType == 'expense' ? -amount : amount; // Mengembalikan efek ke budget
      await remoteDataSource.updateBudgetSpent(budgetId, amountChange);
    }
  }

  @override
  Stream<List<TransactionEntity>> getTransactionsStream() {
    // DataSource sekarang mengembalikan Stream<List<TransactionModel>>.
    // Kita perlu memetakan (map) setiap TransactionModel di dalam stream menjadi TransactionEntity.
    return remoteDataSource.getTransactionsStream().map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  // Implementasi getTransactionById dari interface FinanceRepository
  Future<TransactionEntity?> getTransactionById(String id) async {
    final transactionModel = await remoteDataSource.getTransactionById(id);
    return transactionModel?.toEntity(); // Konversi TransactionModel ke TransactionEntity
  }
}