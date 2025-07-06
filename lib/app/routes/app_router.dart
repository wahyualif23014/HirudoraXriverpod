// lib/app/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hirudorax/features/activities/presentation/pages/activity_detail_page.dart';
import 'package:hirudorax/features/activities/presentation/pages/add_activity_page.dart';
import 'package:hirudorax/features/habits/domain/entities/habit_entity.dart';
import 'package:hirudorax/features/habits/presentation/page/add_habit_page.dart';
import 'package:hirudorax/features/habits/presentation/page/habit_detail_page.dart';

// --- Impor halaman-halaman Anda yang akan digunakan ---
// PASTIKAN SEMUA IMPOR INI SUDAH BENAR PATH-NYA DAN FILENYA ADA
// Jika file halaman belum ada, Anda bisa membuatnya dengan StatelessWidget/ConsumerWidget sederhana
// yang mengembalikan Scaffold dengan Text sebagai placeholder.

// Halaman Dashboard/Home
import '../../features/home/presentation/pages/dasboard.dart';

// Halaman Fitur Finance
import '../../features/finance/presentation/pages/finance_overview_page.dart';
import '../../features/finance/presentation/pages/budget_page.dart';
import '../../features/finance/presentation/pages/add_transaction.dart'; // <--- Pastikan nama file dan class sudah benar

// Halaman Fitur Activities (DI-UNCOMMENT)
import '../../features/activities/presentation/pages/activities_page.dart';
// import '../../features/activities/presentation/pages/add_activity_page.dart';
// import '../../features/activities/presentation/pages/activity_detail_page.dart';

// Halaman Fitur Habits (DI-UNCOMMENT)
import '../../features/habits/presentation/page/habits_page.dart';
// import '../../features/habits/presentation/pages/add_habit_page.dart';
// import '../../features/habits/presentation/pages/habit_detail_page.dart';

// Halaman Fitur Goals (Placeholder)
// import '../../features/goals/presentation/pages/goals_page.dart';
// import '../../features/goals/presentation/pages/add_goal_page.dart';
// import '../../features/goals/presentation/pages/goal_detail_page.dart';

// Halaman Fitur Settings (DI-UNCOMMENT)
// import '../../features/settings/presentation/pages/settings_page.dart';

// Impor definisi rute
import 'routes.dart';

// --- Provider untuk GoRouter ---
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation:
        AppRoutes.homePath, // Aplikasi akan LANGSUNG ke halaman Home/Dashboard

    // Logika pengalihan (redirect) tetap DITONAKTIFKAN SEMENTARA
    // redirect: (BuildContext context, GoRouterState state) { /* ... */ },
    routes: <GoRoute>[
      // --- Main Application Routes ---
      GoRoute(
        path: AppRoutes.homePath,
        builder: (context, state) => const DashboardPage(),
      ),

      // --- Finance Feature Routes ---
      GoRoute(
        path: AppRoutes.financeHubPath,
        builder: (context, state) => const FinanceOverviewPage(),
        routes: [
          GoRoute(
            path: 'add-transaction', // Nested: /finance/add-transaction
            builder:
                (context, state) =>
                    const AddTransactionPage(), 
          ),
          GoRoute(
            path: 'budgets', // Nested: /finance/budgets
            builder: (context, state) => const BudgetPage(),
          ),
          GoRoute(
            path: 'goals', // Nested: /finance/goals (Financial Goals)
            builder:
                (context, state) =>
                    const Text('Financial Goals Page (Coming Soon)'),
          ),
        ],
      ),

      // --- Activities Feature Routes ---
      GoRoute(
        path: AppRoutes.activitiesHubPath, 
        builder:
            (context, state) =>
                const ActivitiesPage(), 
        routes: [
          GoRoute(
            path: 'add', // Nested: /activities/add
            builder:
                (context, state) =>
                    const AddActivityPage(), // Menggunakan halaman tambah
          ),
          GoRoute(
            path: ':id', // Nested: /activities/:id
            builder: (context, state) {
              final activityId = state.pathParameters['id'];
              return ActivityDetailPage(
                activityId: activityId!,
              );
            },
          ),
        ],
      ),

      // --- Habits Feature Routes (DI-UNCOMMENT SELURUH BLOK INI) ---
      GoRoute(
      path: AppRoutes.habitsHubPath, // Path: /habits
      builder: (context, state) => const HabitsPage(), 
      routes: [
        GoRoute(
          path: 'add', // Nested: /habits/add
          builder: (context, state) {
            final HabitEntity? editingHabit = state.extra as HabitEntity?;
            return AddHabitPage(editingHabit: editingHabit);
          },
        ),
        GoRoute(
          path: ':id', // Nested: /habits/:id
          builder: (context, state) {
            final habitId = state.pathParameters['id']!;
            return HabitDetailPage(habitId: habitId);
          },
        ),
      ],
    ),

      // --- Goals Feature Routes (Ini sudah OK) ---
      GoRoute(
        path: AppRoutes.goalsHubPath, // Hub utama Goals
        builder: (context, state) => const Text('Goals Hub Page (Coming Soon)'),
        routes: [
          GoRoute(
            path: 'add', // Nested: /goals/add
            builder:
                (context, state) => const Text('Add Goal Page (Coming Soon)'),
          ),
          GoRoute(
            path: ':id', // Nested: /goals/:id
            builder: (context, state) {
              final goalId = state.pathParameters['id'];
              return Text('Goal Detail Page for ID: $goalId');
            },
          ),
        ],
      ),

      // --- Settings Feature Routes (DI-UNCOMMENT SELURUH BLOK INI) ---
      //   GoRoute(
      //     path: AppRoutes.settingsPath,
      //     builder: (context, state) => const SettingsPage(), // <--- DI-UNCOMMENT
      //     routes: [
      //       GoRoute(
      //         path: 'notifications', // Nested: /settings/notifications
      //         builder: (context, state) => const Text('Notification Settings Page (Coming Soon)'), // Placeholder OK
      //       ),
      //     ],
      //   ),
    ],

    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text('Halaman tidak ditemukan: ${state.error}')),
        ),
  );
});
