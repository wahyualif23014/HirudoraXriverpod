// lib/features/habits/data/providers/habit_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hirudorax/features/activities/data/provider/activity_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import entities
import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habits_repository.dart';

// datasource
import '../datasource/habit_remote_data_source.dart';

// reposi
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/habit_repository_impl.dart';


final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  // Pastikan Supabase diinisialisasi di main() Anda
  // Supabase.initialize(url: 'YOUR_SUPABASE_URL', anonKey: 'YOUR_SUPABASE_ANON_KEY');
  return Supabase.instance.client;
});

// 2. Habit Remote Data Source Provider
final habitRemoteDataSourceProvider = Provider<HabitRemoteDataSource>((ref) {
  return HabitRemoteDataSourceImpl(ref.read(supabaseClientProvider));
});

// 3. Habit Repository Provider
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(ref.read(habitRemoteDataSourceProvider));
});

// 4. Habit Notifier (Untuk operasi CRUD: Add, Update, Delete Habit)
// Mengelola state loading/error untuk operasi asinkron
class HabitNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Tidak ada state awal yang perlu dibangun secara asinkron untuk notifier ini.
    // Init state dari notifier ini akan menjadi AsyncData(null) secara default.
  }

  Future<void> addHabit(HabitEntity habit) async {
    state = const AsyncLoading(); // Set state loading
    try {
      await ref.read(habitRepositoryProvider).addHabit(habit);
      state = const AsyncData(null); // Set state sukses
    } catch (e, st) {
      state = AsyncError(e, st); // Set state error
      rethrow; // Lempar kembali error agar bisa ditangkap di UI
    }
  }

  Future<void> updateHabit(HabitEntity habit) async {
    state = const AsyncLoading();
    try {
      await ref.read(habitRepositoryProvider).updateHabit(habit);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    state = const AsyncLoading();
    try {
      await ref.read(habitRepositoryProvider).deleteHabit(habitId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Metode untuk menandai habit sebagai selesai/belum selesai
  // Ini akan menambah atau menghapus HabitCompletionEntity
  Future<void> toggleHabitCompletion(String habitId, bool completed, {int actualValue = 1}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(habitRepositoryProvider);
      final currentUserId = Supabase.instance.client.auth.currentUser?.id; // Bisa null jika tanpa login

      if (completed) {
        // Tandai selesai: Tambah entri completion baru
        final completion = HabitCompletionEntity(
          habitId: habitId,
          userId: currentUserId, // Bisa null
          completionDate: DateTime.now(), // Tanggal hari ini
          actualValue: actualValue,
          completedAt: DateTime.now(),
        );
        await repo.addHabitCompletion(completion);
      } else {
        // Tandai belum selesai: Hapus entri completion hari ini untuk habit ini
        final today = DateTime.now();
        // Dapatkan semua completion untuk habit ini, lalu cari yang hari ini
        final allCompletions = await repo.getHabitCompletions(habitId: habitId, userId: currentUserId);
        final completionToRemove = allCompletions.firstWhere(
          (c) => c.completionDate.year == today.year &&
                 c.completionDate.month == today.month &&
                 c.completionDate.day == today.day,
          // Jika tidak ditemukan, abaikan atau lempar error
          // Ini perlu penanganan error jika completion tidak ada (misal: user double-tap)
          orElse: () => throw Exception('Completion record for today not found for habit $habitId'),
        );
        await repo.deleteHabitCompletion(completionToRemove.id);
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final habitNotifierProvider = AsyncNotifierProvider<HabitNotifier, void>(
  HabitNotifier.new,
);

// 5. StreamProvider untuk Semua Habits Pengguna
// Ini akan memancarkan List<HabitEntity> secara real-time
final habitsStreamProvider = StreamProvider.autoDispose<List<HabitEntity>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id; // Bisa null
  return ref.read(habitRepositoryProvider).getHabitsStream(userId: userId);
});

// 6. StreamProvider untuk Semua Habit Completions Pengguna (Opsional, untuk statistik lebih lanjut)
final habitCompletionsStreamProvider = StreamProvider.autoDispose<List<HabitCompletionEntity>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id; // Bisa null
  return ref.read(habitRepositoryProvider).getHabitCompletionsStream(userId: userId);
});


// 7. Provider untuk Mendapatkan Completions Harian untuk sebuah Habit
// Ini akan digunakan untuk menentukan apakah sebuah habit "completed today"
final habitIsCompletedTodayProvider = Provider.family.autoDispose<bool, String>((ref, habitId) {
  final userId = Supabase.instance.client.auth.currentUser?.id; // Bisa null
  final completionsAsyncValue = ref.watch(
    habitCompletionsStreamProvider.select((completionsAsync) {
      return completionsAsync.when(
        data: (completions) {
          // Filter completion hanya untuk habitId ini
          // dan untuk tanggal hari ini
          final today = DateTime.now();
          return completions.any((c) =>
              c.habitId == habitId &&
              c.completionDate.year == today.year &&
              c.completionDate.month == today.month &&
              c.completionDate.day == today.day &&
              (userId == null || c.userId == userId)); // Filter by userId jika tidak null
        },
        loading: () => false, // Default to false when loading
        error: (e, st) => false, // Default to false on error
      );
    }),
  );
  return completionsAsyncValue; // Mengembalikan boolean
});


// 8. Provider untuk Ringkasan Kebiasaan Harian (untuk Home Page & HabitsHubPage)
// Menggunakan data dari habitsStreamProvider dan habitIsCompletedTodayProvider
final dailyHabitSummaryProvider = Provider.autoDispose<Map<String, int>>((ref) {
  final habitsAsyncValue = ref.watch(habitsStreamProvider);

  return habitsAsyncValue.when(
    data: (habits) {
      int totalDailyHabits = 0;
      int completedToday = 0;

      for (final habit in habits) {
        // Hitung hanya kebiasaan harian atau yang relevan untuk hari ini
        final isRelevantToday = _isHabitRelevantToday(habit);
        if (isRelevantToday) {
          totalDailyHabits++;
          // Watch provider completion untuk setiap habit
          final isCompleted = ref.watch(habitIsCompletedTodayProvider(habit.id));
          if (isCompleted) {
            completedToday++;
          }
        }
      }

      return {
        'total': totalDailyHabits,
        'completedToday': completedToday,
      };
    },
    loading: () => {'total': 0, 'completedToday': 0},
    error: (e, st) => {'total': 0, 'completedToday': 0},
  );
});

// Helper function untuk menentukan relevansi kebiasaan hari ini
bool _isHabitRelevantToday(HabitEntity habit) {
  final now = DateTime.now();
  if (habit.frequency == HabitFrequency.daily) {
    return true;
  }
  if (habit.frequency == HabitFrequency.weekly) {
    // Anda bisa tambahkan logika di sini jika 'weekly' berarti 'x kali seminggu'
    // Untuk saat ini, kita asumsikan 'weekly' adalah seperti 'daily' tapi dengan target mingguan
    // atau jika weekly berarti di hari tertentu tapi tidak diatur di daysOfWeek
    // Untuk contoh ini, kita asumsikan weekly selalu relevan kecuali ada daysOfWeek
    if (habit.daysOfWeek.isEmpty) return true; // Relevan setiap hari jika weekly tanpa hari spesifik
    final currentDay = now.weekday; // Senin=1, Minggu=7
    return habit.daysOfWeek.contains(currentDay);
  }
  if (habit.frequency == HabitFrequency.custom) {
    final currentDay = now.weekday; // Senin=1, Minggu=7
    return habit.daysOfWeek.contains(currentDay);
  }
  return false;
}
