
class AppRoutes {

  // Main App Routes
  static const String homePath = '/'; // Dashboard/Home Page
  static const String dashboardPath = '/home';

  // Finance Routes
  static const String financeOverviewPath = '/finance-overview';
  static const String addTransactionPath = '/add-transaction';
  static const String budgetManagementPath = '/budget-management';
  static const String financialGoalsPath = '/financial-goals';

  // Activities Routes
  static const String activitiesPath = '/activities';
  static const String addActivityPath = '/add-activity';
  static String activityDetailPath(String id) => '/activities/$id'; // Contoh rute dinamis

  // Personal Development Routes (Jika ada fitur yang terpisah dari habits/goals)
  static const String personalDevPath = '/personal-dev';

  // Settings Routes
  static const String settingsPath = '/settings';
  static const String notificationSettingsPath = '/notification-settings';

}