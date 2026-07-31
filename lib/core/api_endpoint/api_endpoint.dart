class ApiEndpoint {
  static String baseUrl =
      'https://mess-manager-backend-dz5y.onrender.com/api/v1';

  static String login = "$baseUrl/auth/login";
  static String users = "$baseUrl/users";
  static String assignManager = "$baseUrl/months/assign-manager";
  static String currentMonth = "$baseUrl/months/current";
  static String mealsBatch = "$baseUrl/meals/batch";
  static String meals = "$baseUrl/meals";
  static String expenses = "$baseUrl/expenses";
  static String deposits = "$baseUrl/deposits";
  static String summary = "$baseUrl/summary";
}
