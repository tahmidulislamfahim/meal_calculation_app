import 'package:get/get.dart';
import 'package:meal_calculation_app/features/auth/screens/login_screen.dart';
import 'package:meal_calculation_app/features/manager/screens/add_deposit_screen.dart';
import 'package:meal_calculation_app/features/manager/screens/add_expense_screen.dart';
import 'package:meal_calculation_app/features/manager/screens/daily_meal_grid_screen.dart';
import 'package:meal_calculation_app/features/splash/screens/splash_screen.dart';
import 'package:meal_calculation_app/features/summary/screens/member_dashboard_screen.dart';
import 'package:meal_calculation_app/features/super_admin/screens/assign_manager_screen.dart';
import 'package:meal_calculation_app/features/super_admin/screens/create_user_screen.dart';

import 'package:meal_calculation_app/features/manager/screens/manage_expenses_screen.dart';
import 'package:meal_calculation_app/features/manager/screens/manage_deposits_screen.dart';

import 'package:meal_calculation_app/features/super_admin/screens/manage_roommates_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String dailyMealGrid = '/daily-meal-grid';
  static const String addExpense = '/add-expense';
  static const String addDeposit = '/add-deposit';
  static const String manageExpenses = '/manage-expenses';
  static const String manageDeposits = '/manage-deposits';
  static const String createUser = '/create-user';
  static const String manageRoommates = '/manage-roommates';
  static const String assignManager = '/assign-manager';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: dashboard,
      page: () => const MemberDashboardScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: dailyMealGrid,
      page: () => const DailyMealGridScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: addExpense,
      page: () => const AddExpenseScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: addDeposit,
      page: () => const AddDepositScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: manageExpenses,
      page: () => const ManageExpensesScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: manageDeposits,
      page: () => const ManageDepositsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: createUser,
      page: () => const CreateUserScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: manageRoommates,
      page: () => const ManageRoommatesScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: assignManager,
      page: () => const AssignManagerScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
