// lib/app/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// --- Impor halaman-halaman Anda yang akan digunakan ---
// PASTIKAN SEMUA IMPOR INI SUDAH BENAR PATH-NYA DAN FILENYA ADA
// Jika file halaman belum ada, Anda bisa membuatnya dengan StatelessWidget/ConsumerWidget sederhana
// yang mengembalikan Scaffold dengan Text sebagai placeholder.

// Halaman Autentikasi (tetap dikomentari karena kita tidak fokus di sini dulu)
// import '../../features/auth/ui/sign_in_page.dart';
// import '../../features/auth/ui/register_page.dart';

// Halaman Dashboard/Home (Perhatikan perubahan path ke 'home/presentation/pages/dasboard.dart')
import '../../features/home/presentation/pages/dasboard.dart'; 

// Halaman Fitur Finance
import '../../features/finance/presentation/pages/finance_overview_page.dart';
// import '../../features/finance/presentation/pages/budget_page.dart';
// import '../../features/finance/presentation/pages/add_transaction_page.dart';

// Halaman Fitur Activities
// import '../../features/activities/presentation/pages/activities_page.dart';
// import '../../features/activities/presentation/pages/add_activity_page.dart'; // Buat jika ingin halaman terpisah
// import '../../features/activities/presentation/pages/activity_detail_page.dart'; // Buat jika ingin halaman terpisah

// Halaman Fitur Habits
// import '../../features/habits/presentation/pages/habits_page.dart';
// import '../../features/habits/presentation/pages/add_habit_page.dart'; // Buat jika ingin halaman terpisah
// import '../../features/habits/presentation/pages/habit_detail_page.dart'; // Buat jika ingin halaman terpisah

// Halaman Fitur Goals (Placeholder untuk saat ini)
// import '../../features/goals/presentation/pages/goals_page.dart';
// import '../../features/goals/presentation/pages/add_goal_page.dart';
// import '../../features/goals/presentation/pages/goal_detail_page.dart';

// Halaman Fitur Settings
// import '../../features/settings/presentation/pages/settings_page.dart'; 

// Impor definisi rute
import 'routes.dart';

// --- Provider untuk GoRouter ---
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.homePath, // Aplikasi akan LANGSUNG ke halaman Home/Dashboard
    
    // Logika pengalihan (redirect) tetap DITONAKTIFKAN SEMENTARA
    // redirect: (BuildContext context, GoRouterState state) { /* ... */ },
    
    routes: <GoRoute>[
      // --- Authentication Routes (Dikomenterikan) ---

      // --- Main Application Routes ---
      // Home/Dashboard Page: Menampilkan ringkasan dari semua fitur
      GoRoute(
        path: AppRoutes.homePath,
        builder: (context, state) => const DashboardPage(), // <--- DI-UNCOMMENT
      ),

      // --- Finance Feature Routes ---
  //     GoRoute(
  //       path: AppRoutes.financeHubPath, // Hub utama Finance
  //       builder: (context, state) => const FinanceOverviewPage(), // <--- DI-UNCOMMENT
  //       routes: [
  //         GoRoute(
  //           path: 'add-transaction', // Nested: /finance/add-transaction
  //           // builder: (context, state) => const AddTransactionPage(), // <--- DI-UNCOMMENT
  //         ),
  //         GoRoute(
  //           path: 'budgets', // Nested: /finance/budgets
  //           builder: (context, state) => const BudgetPage(), // <--- DI-UNCOMMENT
  //         ),
  //         GoRoute(
  //           path: 'goals', // Nested: /finance/goals (Financial Goals)
  //           builder: (context, state) => const Text('Financial Goals Page (Coming Soon)'), // Placeholder OK
  //         ),
  //       ],
  //     ),

  //     // --- Activities Feature Routes ---
  //     GoRoute(
  //       path: AppRoutes.activitiesHubPath, // Hub utama Activities
  //       builder: (context, state) => const ActivitiesPage(), // <--- DI-UNCOMMENT
  //       routes: [
  //         GoRoute(
  //           path: 'add', // Nested: /activities/add
  //           builder: (context, state) => const Text('Add Activity Page (Coming Soon)'), // Placeholder OK
  //         ),
  //         GoRoute(
  //           path: ':id', // Nested: /activities/:id
  //           builder: (context, state) {
  //             final activityId = state.pathParameters['id'];
  //             return Text('Activity Detail Page for ID: $activityId'); // Placeholder OK
  //           },
  //         ),
  //       ],
  //     ),

  //     // --- Habits Feature Routes ---
  //     GoRoute(
  //       path: AppRoutes.habitsHubPath, // Hub utama Habits
  //       builder: (context, state) => const HabitsPage(), // <--- DI-UNCOMMENT
  //       routes: [
  //         GoRoute(
  //           path: 'add', // Nested: /habits/add
  //           builder: (context, state) => const Text('Add Habit Page (Coming Soon)'), // Placeholder OK
  //         ),
  //         GoRoute(
  //           path: ':id', // Nested: /habits/:id
  //           builder: (context, state) {
  //             final habitId = state.pathParameters['id'];
  //             return Text('Habit Detail Page for ID: $habitId'); // Placeholder OK
  //           },
  //         ),
  //       ],
  //     ),

  //     // --- Goals Feature Routes ---
  //     GoRoute(
  //       path: AppRoutes.goalsHubPath, // Hub utama Goals
  //       builder: (context, state) => const Text('Goals Hub Page (Coming Soon)'), // Placeholder OK
  //       routes: [
  //         GoRoute(
  //           path: 'add', // Nested: /goals/add
  //           builder: (context, state) => const Text('Add Goal Page (Coming Soon)'), // Placeholder OK
  //         ),
  //         GoRoute(
  //           path: ':id', // Nested: /goals/:id
  //           builder: (context, state) {
  //             final goalId = state.pathParameters['id'];
  //             return Text('Goal Detail Page for ID: $goalId'); // Placeholder OK
  //           },
  //         ),
  //       ],
  //     ),

  //     // --- Settings Feature Routes ---
  //     GoRoute(
  //       path: AppRoutes.settingsPath,
  //       builder: (context, state) => const SettingsPage(), // <--- DI-UNCOMMENT
  //       routes: [
  //         GoRoute(
  //           path: 'notifications', // Nested: /settings/notifications
  //           builder: (context, state) => const Text('Notification Settings Page (Coming Soon)'), // Placeholder OK
  //         ),
  //       ],
  //     ),
    ],
    
  //   errorBuilder: (context, state) => Scaffold(
  //     appBar: AppBar(title: const Text('Error')),
  //     body: Center(child: Text('Halaman tidak ditemukan: ${state.error}')),
  //   ),
  );
});