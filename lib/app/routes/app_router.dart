// lib/app/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hirudorax/features/activities/domain/entity/activity_entity.dart';
import 'package:hirudorax/features/activities/presentation/pages/activity_detail_page.dart';
import 'package:hirudorax/features/activities/presentation/pages/add_activity_page.dart';
import 'package:hirudorax/features/habits/domain/entities/habit_entity.dart';
import 'package:hirudorax/features/habits/presentation/page/add_habit_page.dart';
import 'package:hirudorax/features/habits/presentation/page/habit_detail_page.dart';


// Halaman Dashboard/Home
import '../../features/home/presentation/pages/dasboard.dart';

// Halaman Fitur Finance
import '../../features/finance/presentation/pages/finance_overview_page.dart';
import '../../features/finance/presentation/pages/budget_page.dart';
import '../../features/finance/presentation/pages/add_transaction.dart'; // <--- clear

// Halaman Fitur Activities (DI-UNCOMMENT)
import '../../features/activities/presentation/pages/activities_page.dart';
// import '../../features/activities/presentation/pages/add_activity_page.dart';
// import '../../features/activities/presentation/pages/activity_detail_page.dart';

// Halaman Fitur Habits (DI-UNCOMMENT)
import '../../features/habits/presentation/page/habits_page.dart';
// import '../../features/habits/presentation/page/add_habit_page.dart';
// import '../../features/habits/presentation/page/habit_detail_page.dart';

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
    initialLocation: AppRoutes.homePath,

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
            path: 'add-transaction', 
            builder: (context, state) => const AddTransactionPage(),
          ),
          GoRoute(
            path: 'budgets', 
            builder: (context, state) => const BudgetPage(),
          ),
          GoRoute(
            path: 'goals', 
            builder:
                (context, state) =>
                    const Text('Financial Goals Page (Coming Soon)'),
          ),
        ],
      ),

      // --- Activities Feature Routes ---
      GoRoute(
        path: '/activities',
        name: AppRoutes.activitiesHubPath, 
        builder: (context, state) => const ActivitiesPage(),
        routes: [
          GoRoute(
            path: 'add',
            name: AppRoutes.addActivityPath,
            builder: (context, state) {
              final ActivityEntity? editingActivity =
                  state.extra as ActivityEntity?;
              return AddActivityPage(editingActivity: editingActivity);
            },
          ),
          GoRoute(
            path: ':id', 
            name: 'activityDetail', 
            builder: (context, state) {
              final activityId = state.pathParameters['id']!;
              return ActivityDetailPage(activityId: activityId);
            },
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.habitsHubPath, 
        builder: (context, state) => const HabitsPage(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) {
              final HabitEntity? editingHabit = state.extra as HabitEntity?;
              return AddHabitPage(editingHabit: editingHabit);
            },
          ),
          GoRoute(
            path: ':id', 
            name: 'habitDetail',
            builder: (context, state) {
              final habitId = state.pathParameters['id']!;
              return HabitDetailPage(habitId: habitId);
            },
          ),
        ],
      ),

      // --- Goals Feature Routes (Ini sudah OK) ---
      GoRoute(
        path: AppRoutes.goalsHubPath, 
        builder: (context, state) => const Text('Goals Hub Page (Coming Soon)'),
        routes: [
          GoRoute(
            path: 'add', 
            builder:
                (context, state) => const Text('Add Goal Page (Coming Soon)'),
          ),
          GoRoute(
            path: ':id', 
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
