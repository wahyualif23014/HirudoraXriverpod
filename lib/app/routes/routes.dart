// lib/app/routes/routes.dart


class AppRoutes {
  // // --- Authentication Routes ---
  // static const String signInPath = '/sign-in';
  // static const String signUpPath = '/sign-up';

  // --- Main Application Routes ---
  static const String homePath = '/'; 

  // --- Finance Feature Routes ---
  static const String financeHubPath = '/finance'; 
  static const String addTransactionPath = '/finance/add-transaction';
  static const String budgetManagementPath = '/finance/budgets';
  static const String financialGoalsPath = '/finance/goals'; 

  // --- Activities Feature Routes ---
  static const String activitiesHubPath = '/activities'; 
  static const String addActivityPath = '/activities/add'; 
  static String activityDetailPath(String id) => '/activities/$id'; 

  // --- Habits Feature Routes (Bagian dari Pengembangan Diri) ---
  static const String habitsHubPath = '/habits'; 
  static const String addHabitPath = '/habits/add'; 
  static String habitDetailPath(String id) => '/habits/$id';

  // --- Goals Feature Routes (Bagian dari Pengembangan Diri) ---
  static const String goalsHubPath = '/goals'; 
  static const String addGoalPath = '/goals/add'; 
  static String goalDetailPath(String id) => '/goals/$id';

  // --- Settings Feature Routes ---
  static const String settingsPath = '/settings';
  static const String notificationSettingsPath = '/settings/notifications';
}