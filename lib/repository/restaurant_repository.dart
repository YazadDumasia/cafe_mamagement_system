import '../database/database_helper.dart' as dh;
import '../model/recipe/recipe_model.dart';
import '../model/category.dart';
import '../model/sub_category.dart';
import '../model/menu_item.dart';
import '../model/customer.dart';
import '../model/order_model/order_model.dart';
import '../model/invoices/invoice_model.dart';
import '../model/invoices/invoice_item_model.dart';
import '../model/invoices/payment_transaction_model.dart';
import '../model/inventory_model/inventory_model.dart';
import '../model/purchase_model/purchase_model.dart';
import '../model/attendance/employee.dart';
import '../model/attendance/attendance.dart';
import '../model/attendance/leave.dart';
import '../model/table_info_model.dart';
import '../model/menu_item_review.dart';
import '../model/reports/sales_summary_model.dart';
import '../model/reports/sales_graph_model.dart';
import '../model/reports/payment_mode_report_model.dart';
import '../model/reports/top_selling_item_model.dart';
import '../model/reports/sales_forecast_model.dart';
import '../model/reports/sales_dasdboard_model.dart';
import '../utils/components/constants.dart';

class RestaurantRepository {
  final _databaseHelper = dh.DatabaseHelper.instance;

  RestaurantRepository() {
    dh.DatabaseHelper.instance.database;
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Executes a database operation with consistent error handling and logging
  Future<T?> _executeWithLogging<T>(
    String methodName,
    Future<T?> Function() operation, {
    bool trackExecutionTime = false,
  }) async {
    final buildmode = await Constants.getCurrentPlatformBuildMode();
    if (buildmode == 'release') {
      return await operation();
    } else {
      final stopwatch = trackExecutionTime ? (Stopwatch()..start()) : null;

      try {
        final result = await operation();

        if (stopwatch != null) {
          stopwatch.stop();
          Constants.debugLog(
            RestaurantRepository,
            "Execution time:$methodName:${stopwatch.elapsedMilliseconds} ms",
          );
        }

        return result;
      } catch (e) {
        if (stopwatch != null) {
          stopwatch.stop();
          Constants.debugLog(
            RestaurantRepository,
            "Error in $methodName:$e, time:${stopwatch.elapsedMilliseconds} ms",
          );
        } else {
          Constants.debugLog(RestaurantRepository, 'Error in $methodName: $e');
        }
      }
    }
    return null;
  }

  // ========================================
  // DATABASE MANAGEMENT
  // ========================================

  /// Clears a table in the database
  Future<void> clearTable(String tableName) async {
    return await _executeWithLogging(
      'clearTable',
      () => _databaseHelper.clearTable(tableName),
    );
  }

  /// Resets the database by clearing all tables
  Future<void> resetDatabase() async {
    return await _executeWithLogging(
      'resetDatabase',
      () => _databaseHelper.clearAllTables(),
    );
  }

  /// Wipes the entire database file from disk.
  Future<void> wipeDatabase() async {
    return await _executeWithLogging(
      'wipeDatabase',
      () => _databaseHelper.wipeDatabase(),
    );
  }

  /// Backs up the database and returns the backup file path
  Future<void> backupDatabase({
    bool encryptBackup = true,
    void Function(double progress, String status)? onProgress,
  }) async {
    return await _executeWithLogging(
      'backupDatabase',
      () => _databaseHelper.backupDatabase(
        encryptBackup: encryptBackup,
        onProgress: onProgress,
      ),
    );
  }

  /// Restores the database from a backup file
  Future<void> restoreDatabase(
    String backupFilePath, {
    void Function(double progress, String status)? onProgress,
  }) async {
    return await _executeWithLogging(
      'restoreDatabase',
      () => _databaseHelper.restoreDatabase(
        backupFilePath,
        onProgress: onProgress,
      ),
    );
  }

  ///Daily backup the database with optional encryption and progress callback
  // This method can be scheduled to run daily using a background task scheduler
  Future<void> dailyBackup({
    bool encryptBackup = true,
    void Function(double progress, String status)? onProgress,
  }) async {
    return await _executeWithLogging(
      'dailyBackup',
      () => _databaseHelper.backupCurrentDayOrdersAndInvoices(
        encryptBackup: encryptBackup,
        onProgress: onProgress,
      ),
    );
  }

  ///Weekly backup the database with optional encryption and progress callback
  /// This method can be scheduled to run weekly using a background task scheduler
  Future<void> weeklyBackup(
    DateTime startDate,
    DateTime endDate, {
    String filePrefix = 'coozy_orders_invoices',
    bool encryptBackup = true,
    void Function(double progress, String status)? onProgress,
  }) async {
    await _executeWithLogging(
      'weeklyBackup',
      () => _databaseHelper.backupOrdersAndInvoicesRange(
        startDate,
        endDate,
        filePrefix: filePrefix,
        encryptBackup: encryptBackup,
        onProgress: onProgress,
      ),
    );
  }

  Future<String?> getDbPath() async {
    return await _executeWithLogging(
      'getDbPath',
      () => _databaseHelper.getDbPath(),
    );
  }

  Future<void> clearDatabase() async {
    await _executeWithLogging(
      'clearDatabase',
      () => _databaseHelper.clearDatabase(),
    );
  }

  // ========================================
  // RECIPE MANAGEMENT
  // ========================================

  Future<void> insertRecipes(List<RecipeModel> recipes) async {
    await _executeWithLogging(
      'insertRecipes',
      () => _databaseHelper.insertRecipes(recipes),
    );
  }

  Future<void> insertRecipesChunked(List<RecipeModel>? recipes) async {
    await _executeWithLogging(
      'insertRecipesChunked',
      () => _databaseHelper.insertRecipesChunked(recipes),
    );
  }

  Future<int?> updateRecipe(RecipeModel recipe) async {
    return await _executeWithLogging(
      'updateRecipe',
      () => _databaseHelper.updateRecipe(recipe),
    );
  }

  Future<int?> deleteRecipe({int? id}) async {
    return await _executeWithLogging(
      'deleteRecipe',
      () => _databaseHelper.deleteRecipe(id: id),
    );
  }

  Future<List<RecipeModel>?> getRecipes({int chunkSize = 200}) async {
    return await _executeWithLogging(
      'getRecipes',
      () => _databaseHelper.getRecipes(chunkSize: chunkSize),
    );
  }

  Future<List<RecipeModel>?> getBookmarkedRecipes() async {
    return await _executeWithLogging(
      'getBookmarkedRecipes',
      () => _databaseHelper.getBookmarkedRecipes(),
    );
  }

  Future<void> processRecipeIngredients({
    int chunkSize = 200,
    void Function(double progress)? onProgress,
  }) async {
    await _executeWithLogging(
      'processRecipeIngredients',
      () => _databaseHelper.processRecipeIngredients(
        chunkSize: chunkSize,
        onProgress: onProgress,
      ),
    );
  }

  Future<void> processSingleRecipeIngredients(RecipeModel recipe) async {
    await _executeWithLogging(
      'processSingleRecipeIngredients',
      () => _databaseHelper.processSingleRecipeIngredients(recipe),
    );
  }

  Future<List<String>?> extractIngredients(String rawIngredients) async {
    return await _executeWithLogging(
      'extractIngredients',
      () async => _databaseHelper.extractIngredients(rawIngredients),
    );
  }

  Future<List<Map<String, dynamic>>?> searchIngredients(String? searchTerm) async {
    return await _executeWithLogging(
      'searchIngredients',
      () => _databaseHelper.searchIngredients(searchTerm),
    );
  }

  Future<List<Map<String, dynamic>>?> fetchAllIngredients() async {
    return await _executeWithLogging(
      'fetchAllIngredients',
      () => _databaseHelper.fetchAllIngredients(),
    );
  }

  // ========================================
  // CATEGORY MANAGEMENT
  // ========================================

  Future<int?> addCategory(Category category) async {
    return await _executeWithLogging(
      'addCategory',
      () => _databaseHelper.addCategory(category),
    );
  }

  Future<List<Category>?> getCategories() async {
    return await _executeWithLogging(
      'getCategories',
      () => _databaseHelper.getCategories(),
    );
  }

  Future<int?> updateCategory(Category category) async {
    return await _executeWithLogging(
      'updateCategory',
      () => _databaseHelper.updateCategory(category),
    );
  }

  Future<Category?> getCategoryBasedOnName({String? name}) async {
    return await _executeWithLogging(
      'getCategoryBasedOnName',
      () => _databaseHelper.getCategoryBasedOnName(name: name),
    );
  }

  Future<Category?> getCategoryBasedOnCategoryId({
    required int? categoryId,
  }) async {
    return await _executeWithLogging(
      'getCategoryBasedOnCategoryId',
      () => _databaseHelper.getCategoryBasedOnCategoryId(
        categoryId: categoryId,
      ),
    );
  }

  Future<int?> deleteCategory(Category? model) async {
    return await _executeWithLogging(
      'deleteCategory',
      () => _databaseHelper.deleteCategory(model),
    );
  }

  Future<int?> createSubcategory(SubCategory subcategory) async {
    return await _executeWithLogging(
      'createSubcategory',
      () => _databaseHelper.createSubcategory(subcategory),
    );
  }

  Future<List<SubCategory>?> getSubcategories() async {
    return await _executeWithLogging(
      'getSubcategories',
      () => _databaseHelper.getSubcategories(),
    );
  }

  Future<List<SubCategory>?> getSubcategoryBaseCategoryId(int categoryId) async {
    return await _executeWithLogging(
      'getSubcategoryBaseCategoryId',
      () => _databaseHelper.getSubcategoryBaseCategoryId(categoryId),
    );
  }

  Future<int?> updateSubcategory(SubCategory subcategory) async {
    return await _executeWithLogging(
      'updateSubcategory',
      () => _databaseHelper.updateSubcategory(subcategory),
    );
  }

  Future<int?> deleteSubcategory(int id) async {
    return await _executeWithLogging(
      'deleteSubcategory',
      () => _databaseHelper.deleteSubcategory(id),
    );
  }

  Future<int?> deleteAllSubcategoryBasedOnCategoryId({int? categoryId}) async {
    return await _executeWithLogging(
      'deleteAllSubcategoryBasedOnCategoryId',
      () => _databaseHelper.deleteAllSubcategoryBasedOnCategoryId(
        categoryId: categoryId,
      ),
    );
  }

  // ========================================
  // SUBCATEGORY MANAGEMENT
  // ========================================

  Future<void> insertSubCategoriesForCategoryId({
    required int? categoryId,
    required List<SubCategory> subCategories,
  }) async {
    await _executeWithLogging(
      'insertSubCategoriesForCategoryId',
      () => _databaseHelper.insertSubCategoriesForCategoryId(
        categoryId: categoryId,
        subCategories: subCategories,
      ),
    );
  }

  Future<int?> createMenuItem(MenuItem menuItem) async {
    return await _executeWithLogging(
      'createMenuItem',
      () => _databaseHelper.createMenuItem(menuItem),
    );
  }

  // ========================================
  // MENU ITEM MANAGEMENT
  // ========================================

  Future<int?> updateMenuItem(MenuItem menuItem) async {
    return await _executeWithLogging(
      'updateMenuItem',
      () => _databaseHelper.updateMenuItem(menuItem),
    );
  }

  Future<MenuItem?> getMenuItemById(int id) async {
    return await _executeWithLogging(
      'getMenuItemById',
      () => _databaseHelper.getMenuItemById(id),
    );
  }

  Future<void> deleteMenuItem(int? menuItemId) async {
    await _executeWithLogging(
      'deleteMenuItem',
      () => _databaseHelper.deleteMenuItem(menuItemId),
    );
  }

  Future<List<MenuItem>?> getAllMenuItems() async {
    return await _executeWithLogging(
      'getAllMenuItems',
      () => _databaseHelper.getAllMenuItems(),
    );
  }

  Future<List<MenuItem>> getAvailableMenuItems() async {
    return await _executeWithLogging(
      'getAvailableMenuItems',
      () => _databaseHelper.getAvailableMenuItems(),
    ) ?? [];
  }

  Future<List<MenuItem>> getAvailableMenuItemsPagination({
    required int pageNumber,
    required int limit,
    String? searchTerm,
  }) async {
    return await _executeWithLogging(
      'getAvailableMenuItemsPagination',
      () => _databaseHelper.getAvailableMenuItemsPagination(
        pageNumber: pageNumber,
        limit: limit,
        searchTerm: searchTerm,
      ),
    ) ?? [];
  }

  Future<List<MenuItem>> fetchAllMenuItemsPaged({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    return await _executeWithLogging(
      'fetchAllMenuItemsPaged',
      () => _databaseHelper.fetchAllMenuItemsPaged(
        pageNumber: pageNumber,
        limit: limit,
        search: search,
      ),
    ) ?? [];
  }

  Future<int> fetchMenuItemsCount({String? search}) async {
    return await _executeWithLogging(
      'fetchMenuItemsCount',
      () => _databaseHelper.fetchMenuItemsCount(search: search),
    ) ?? 0;
  }

  Future<List<MenuItem>?> fetchAvailableMenuItemsPaged({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    return await _executeWithLogging(
      'fetchAvailableMenuItemsPaged',
      () => _databaseHelper.fetchAvailableMenuItemsPaged(
        pageNumber: pageNumber,
        limit: limit,
        search: search,
      ),
    );
  }

  Future<List<MenuItemReview>> getReviewsForMenuItem(int itemId) async {
    return await _executeWithLogging(
      'getReviewsForMenuItem',
      () => _databaseHelper.getReviewsForMenuItem(itemId),
    ) ?? [];
  }

  Future<double> calculateAverageRatingForMenuItem(int itemId) async {
    return await _executeWithLogging(
      'calculateAverageRatingForMenuItem',
      () => _databaseHelper.calculateAverageRatingForMenuItem(itemId),
    ) ?? 0.0;
  }

  Future<int> createCustomer(Customer customer) async {
    return await _executeWithLogging(
      'createCustomer',
      () => _databaseHelper.createCustomer(customer),
    ) ?? 0;
  }

  // ========================================
  // CUSTOMER MANAGEMENT
  // ========================================

  Future<Customer?> getCustomer(int id) async {
    return await _executeWithLogging(
      'getCustomer',
      () => _databaseHelper.getCustomer(id),
    );
  }

  Future<List<Customer>?> searchCustomers({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    return await _executeWithLogging(
      'searchCustomers',
      () => _databaseHelper.searchCustomers(
        pageNumber: pageNumber,
        limit: limit,
        search: search,
      ),
    );
  }

  Future<bool> isCustomerExist(String searchTerm) async {
    return await _executeWithLogging(
      'isCustomerExist',
      () => _databaseHelper.isCustomerExist(searchTerm),
    ) ?? false;
  }

  Future<int?> updateCustomer(Customer customer) async {
    return await _executeWithLogging(
      'updateCustomer',
      () => _databaseHelper.updateCustomer(customer),
    );
  }

  Future<int?> deleteCustomer(int id) async {
    return await _executeWithLogging(
      'deleteCustomer',
      () => _databaseHelper.deleteCustomer(id),
    );
  }

  // ========================================
  // TABLE INFORMATION
  // ========================================

  Future<int?> addTableInfo(TableInfoModel newTableInfo) async {
    return await _executeWithLogging(
      'addTableInfo',
      () => _databaseHelper.addTableInfo(newTableInfo),
    );
  }

  Future<List<TableInfoModel>?> getTableInfos() async {
    return await _executeWithLogging(
      'getTableInfos',
      () => _databaseHelper.getTableInfos(),
    );
  }

  Future<List<TableInfoModel>?> getTableInfosPage({
    int limit = 20,
    int pageNumber = 1,
  }) async {
    return await _executeWithLogging(
      'getTableInfosPage',
      () => _databaseHelper.getTableInfosPage(
        limit: limit,
        pageNumber: pageNumber,
      ),
    );
  }

  Future<TableInfoModel?> getTableInfo(int id) async {
    return await _executeWithLogging(
      'getTableInfo',
      () => _databaseHelper.getTableInfo(id),
    );
  }

  Future<int?> updateTableInfo(TableInfoModel tableInfo) async {
    return await _executeWithLogging(
      'updateTableInfo',
      () => _databaseHelper.updateTableInfo(tableInfo),
    );
  }

  Future<int> getTableInfoRecordCount() async {
    return await _executeWithLogging(
      'getTableInfoRecordCount',
      () => _databaseHelper.getTableInfoRecordCount(),
    ) ?? 0;
  }

  Future<int?> deleteTableInfo(TableInfoModel model) async {
    return await _executeWithLogging(
      'deleteTableInfo',
      () => _databaseHelper.deleteTableInfo(model),
    );
  }

  // ========================================
  // ORDER MANAGEMENT
  // ========================================

  Future<int?> createNewOrder(OrderModel order) async {
    return await _executeWithLogging(
      'createNewOrder',
      () => _databaseHelper.createNewOrder(order),
    );
  }

  Future<void> updateOrder(OrderModel order) async {
    await _executeWithLogging(
      'updateOrder',
      () => _databaseHelper.updateOrder(order),
    );
  }

  Future<OrderModel?> getOrderInfo(int orderId) async {
    return await _executeWithLogging(
      'getOrderInfo',
      () => _databaseHelper.getOrderInfo(orderId),
    );
  }

  Future<int?> updateOrderIsDeleted(int orderId, bool isDeleted) async {
    return await _executeWithLogging(
      'updateOrderIsDeleted',
      () => _databaseHelper.updateOrderIsDeleted(orderId, isDeleted),
    );
  }

  Future<int?> updateOrderIsCanceled(int orderId, bool isCanceled) async {
    return await _executeWithLogging(
      'updateOrderIsCanceled',
      () => _databaseHelper.updateOrderIsCanceled(orderId, isCanceled),
    );
  }

  // ========================================
  // ORDER QUERY METHODS
  // ========================================

  Future<List<OrderModel>> getAllOrders() async {
    return await _executeWithLogging(
      'getAllOrders',
      () => _databaseHelper.getAllOrders(),
    ) ?? [];
  }

  Future<List<OrderModel>> getAllOrdersWithPagination({
    required int limit,
    required int pageNo,
  }) async {
    return await _executeWithLogging(
      'getAllOrdersWithPagination',
      () => _databaseHelper.getAllOrdersWithPagination(
        limit: limit,
        pageNo: pageNo,
      ),
    ) ?? [];
  }

  Future<List<OrderModel>> getAllActiveOrders() async {
    return await _executeWithLogging(
      'getAllActiveOrders',
      () => _databaseHelper.getAllActiveOrders(),
    ) ?? [];
  }

  Future<List<Map<String, dynamic>>> getOrderedItemsForKitchen(
    String status, {
    int chunkSize = 100,
  }) async {
    return await _executeWithLogging(
      'getOrderedItemsForKitchen',
      () => _databaseHelper.getOrderedItemsForKitchen(
        status,
        chunkSize: chunkSize,
      ),
    ) ?? [];
  }

  // ========================================
  // INVENTORY MANAGEMENT
  // ========================================

  Future<int> insertInventory(InventoryModel inventory) async {
    return await _executeWithLogging(
      'insertInventory',
      () => _databaseHelper.insertInventory(inventory),
    ) ?? 0;
  }

  Future<int> updateInventory(InventoryModel inventory) async {
    return await _executeWithLogging(
      'updateInventory',
      () => _databaseHelper.updateInventory(inventory),
    ) ?? 0;
  }

  Future<int> deleteInventory(int id) async {
    return await _executeWithLogging(
      'deleteInventory',
      () => _databaseHelper.deleteInventory(id),
    ) ?? 0;
  }

  Future<void> insertInventoryBatch(List<InventoryModel> items) async {
    await _executeWithLogging(
      'insertInventoryBatch',
      () => _databaseHelper.insertInventoryBatch(items),
    );
  }

  Future<void> updateInventoryBatch(List<InventoryModel> items) async {
    await _executeWithLogging(
      'updateInventoryBatch',
      () => _databaseHelper.updateInventoryBatch(items),
    );
  }

  Future<void> deleteInventoryBatch(List<int> ids) async {
    await _executeWithLogging(
      'deleteInventoryBatch',
      () => _databaseHelper.deleteInventoryBatch(ids),
    );
  }

  // ========================================
  // PURCHASE MANAGEMENT
  // ========================================

  Future<List<InventoryModel>> getAllEnableInventory() async {
    return await _executeWithLogging(
      'getAllEnableInventory',
      () => _databaseHelper.getAllEnableInventory(),
    ) ?? [];
  }

  Future<List<InventoryModel>> getAllEnableInventoryPage({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    return await _executeWithLogging(
      'getAllEnableInventoryPage',
      () => _databaseHelper.getAllEnableInventoryPage(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
      ),
    ) ?? [];
  }

  Future<List<InventoryModel>> searchInventoryByNameOrDescription({
    required String query,
  }) async {
    return await _executeWithLogging(
      'searchInventoryByNameOrDescription',
      () => _databaseHelper.searchInventoryByNameOrDescription(query: query),
    ) ?? [];
  }

  Future<List<InventoryModel>> getInventory() async {
    return await _executeWithLogging(
      'getInventory',
      () => _databaseHelper.getInventory(),
    ) ?? [];
  }

  Future<List<InventoryModel>> getInventoryPage({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    return await _executeWithLogging(
      'getInventoryPage',
      () => _databaseHelper.getInventoryPage(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
      ),
    ) ?? [];
  }

  Future<List<String>> getEnabledInventoryFirstLetters({
    String? searchQuery,
  }) async {
    return await _executeWithLogging(
      'getEnabledInventoryFirstLetters',
      () => _databaseHelper.getEnabledInventoryFirstLetters(
        searchQuery: searchQuery,
      ),
    ) ?? [];
  }

  Future<List<String>> getAllInventoryFirstLetters({
    String? searchQuery,
  }) async {
    return await _executeWithLogging(
      'getAllInventoryFirstLetters',
      () => _databaseHelper.getAllInventoryFirstLetters(
        searchQuery: searchQuery,
      ),
    ) ?? [];
  }

  Future<int> insertPurchase(PurchaseModel purchase) async {
    return await _executeWithLogging(
      'insertPurchase',
      () => _databaseHelper.insertPurchase(purchase),
    ) ?? 0;
  }

  Future<int> updatePurchase(PurchaseModel purchase) async {
    return await _executeWithLogging(
      'updatePurchase',
      () => _databaseHelper.updatePurchase(purchase),
    ) ?? 0;
  }

  Future<int> deletePurchase(int id) async {
    return await _executeWithLogging(
      'deletePurchase',
      () => _databaseHelper.deletePurchase(id),
    ) ?? 0;
  }

  Future<void> insertPurchaseBatch(List<PurchaseModel> purchases) async {
    await _executeWithLogging(
      'insertPurchaseBatch',
      () => _databaseHelper.insertPurchaseBatch(purchases),
    );
  }

  Future<void> updatePurchaseBatch(List<PurchaseModel> purchases) async {
    await _executeWithLogging(
      'updatePurchaseBatch',
      () => _databaseHelper.updatePurchaseBatch(purchases),
    );
  }

  Future<void> deletePurchaseBatch(List<int> ids) async {
    await _executeWithLogging(
      'deletePurchaseBatch',
      () => _databaseHelper.deletePurchaseBatch(ids),
    );
  }

  Future<List<PurchaseModel>> getAllPurchases() async {
    return await _executeWithLogging(
      'getAllPurchases',
      () => _databaseHelper.getAllPurchases(),
    ) ?? [];
  }

  Future<double> getDailyExpenditureCost(String currentDate) async {
    return await _executeWithLogging(
      'getDailyExpenditureCost',
      () => _databaseHelper.getDailyExpenditureCost(currentDate),
    ) ?? 0.0;
  }

  // ========================================
  // EMPLOYEE MANAGEMENT
  // ========================================

  Future<double> getMonthlyExpenditureCost(String month) async {
    return await _executeWithLogging(
      'getMonthlyExpenditureCost',
      () => _databaseHelper.getMonthlyExpenditureCost(month),
    ) ?? 0.0;
  }

  Future<List<PurchaseModel>> getPurchasesBetweenDates({
    required String fromDateTime,
    required String toDateTime,
  }) async {
    return await _executeWithLogging(
      'getPurchasesBetweenDates',
      () => _databaseHelper.getPurchasesBetweenDates(
        fromDateTime: fromDateTime,
        toDateTime: toDateTime,
      ),
    ) ?? [];
  }

  Future<double> getExpenditureBetweenDates({
    required String fromDateTime,
    required String toDateTime,
  }) async {
    return await _executeWithLogging(
      'getExpenditureBetweenDates',
      () => _databaseHelper.getExpenditureBetweenDates(
        fromDateTime: fromDateTime,
        toDateTime: toDateTime,
      ),
    ) ?? 0.0;
  }

  Future<Map<String, List<Map<String, dynamic>>>> getExpenditureGraphData({
    required String month,
    required String year,
    required String fromDateTime,
    required String toDateTime,
  }) async {
    return await _executeWithLogging(
      'getExpenditureGraphData',
      () => _databaseHelper.getExpenditureGraphData(
        month: month,
        year: year,
        fromDateTime: fromDateTime,
        toDateTime: toDateTime,
      ),
    ) ?? {};
  }

  Future<int> addEmployee(Employee employee) async {
    return await _executeWithLogging(
      'addEmployee',
      () => _databaseHelper.addEmployee(employee),
    ) ?? 0;
  }

  // ========================================
  // ATTENDANCE MANAGEMENT
  // ========================================

  Future<int> updateEmployee(Employee employee) async {
    return await _executeWithLogging(
      'updateEmployee',
      () => _databaseHelper.updateEmployee(employee),
    ) ?? 0;
  }

  Future<int> deleteSoftEmployee(int id) async {
    return await _executeWithLogging(
      'deleteSoftEmployee',
      () => _databaseHelper.deleteSoftEmployee(id),
    ) ?? 0;
  }

  Future<int> deletePermanentEmployee(int id) async {
    return await _executeWithLogging(
      'deletePermanentEmployee',
      () => _databaseHelper.deletePermanentEmployee(id),
    ) ?? 0;
  }

  Future<List<Employee>> getEmployees() async {
    return await _executeWithLogging(
      'getEmployees',
      () => _databaseHelper.getEmployees(),
    ) ?? [];
  }

  Future<List<Employee>> getEmployeesPaged({
    int pageNumber = 1,
    int limit = 20,
  }) async {
    return await _executeWithLogging(
      'getEmployeesPaged',
      () => _databaseHelper.getEmployeesPaged(
        pageNumber: pageNumber,
        limit: limit,
      ),
    ) ?? [];
  }

  Future<int> addAttendance(Attendance attendance) async {
    return await _executeWithLogging(
      'addAttendance',
      () => _databaseHelper.addAttendance(attendance),
    ) ?? 0;
  }

  Future<int> updateAttendance(Attendance attendance) async {
    return await _executeWithLogging(
      'updateAttendance',
      () => _databaseHelper.updateAttendance(attendance),
    ) ?? 0;
  }

  Future<int> deleteAttendance(int id) async {
    return await _executeWithLogging(
      'deleteAttendance',
      () => _databaseHelper.deleteAttendance(id),
    ) ?? 0;
  }

  Future<int> deletePermanentlyAttendance(int id) async {
    return await _executeWithLogging(
      'deletePermanentlyAttendance',
      () => _databaseHelper.deletePermanentlyAttendance(id),
    ) ?? 0;
  }

  Future<int> addLeave(Leave leave) async {
    return await _executeWithLogging(
      'addLeave',
      () => _databaseHelper.addLeave(leave),
    ) ?? 0;
  }

  Future<int> updateLeave(Leave leave) async {
    return await _executeWithLogging(
      'updateLeave',
      () => _databaseHelper.updateLeave(leave),
    ) ?? 0;
  }

  Future<void> updateLeavesBatch(List<Leave> leaves) async {
    await _executeWithLogging(
      'updateLeavesBatch',
      () => _databaseHelper.updateLeavesBatch(leaves),
    );
  }

  Future<int> deleteLeave(int id) async {
    return await _executeWithLogging(
      'deleteLeave',
      () => _databaseHelper.deleteLeave(id),
    ) ?? 0;
  }

  Future<int> deleteLeavePermanent(int id) async {
    return await _executeWithLogging(
      'deleteLeavePermanent',
      () => _databaseHelper.deleteLeavePermanent(id),
    ) ?? 0;
  }

  // ========================================
  // INVOICE MANAGEMENT
  // ========================================

  Future<int> insertInvoice(InvoiceModel invoice) async {
    return await _executeWithLogging(
      'insertInvoice',
      () => _databaseHelper.insertInvoice(invoice),
    ) ?? 0;
  }

  Future<InvoiceModel?> getInvoiceById(int id) async {
    return await _executeWithLogging(
      'getInvoiceById',
      () => _databaseHelper.getInvoiceById(id),
    );
  }

  Future<List<InvoiceModel>> getAllInvoices() async {
    return await _executeWithLogging(
      'getAllInvoices',
      () => _databaseHelper.getAllInvoices(),
    ) ?? [];
  }

  Future<int> updateInvoice(InvoiceModel invoice) async {
    return await _executeWithLogging(
      'updateInvoice',
      () => _databaseHelper.updateInvoice(invoice),
    ) ?? 0;
  }

  Future<int> deleteInvoice(int id) async {
    return await _executeWithLogging(
      'deleteInvoice',
      () => _databaseHelper.deleteInvoice(id),
    ) ?? 0;
  }

  Future<int> insertInvoiceItem(InvoiceItemModel item) async {
    return await _executeWithLogging(
      'insertInvoiceItem',
      () => _databaseHelper.insertInvoiceItem(item),
    ) ?? 0;
  }

  Future<void> insertInvoiceItems(List<InvoiceItemModel> items) async {
    await _executeWithLogging(
      'insertInvoiceItems',
      () => _databaseHelper.insertInvoiceItems(items),
    );
  }

  Future<List<InvoiceItemModel>> getInvoiceItems(int invoiceId) async {
    return await _executeWithLogging(
      'getInvoiceItems',
      () => _databaseHelper.getInvoiceItems(invoiceId),
    ) ?? [];
  }

  Future<int> deleteInvoiceItems(int invoiceId) async {
    return await _executeWithLogging(
      'deleteInvoiceItems',
      () => _databaseHelper.deleteInvoiceItems(invoiceId),
    ) ?? 0;
  }

  Future<int> insertPaymentTransaction(PaymentTransactionModel payment) async {
    return await _executeWithLogging(
      'insertPaymentTransaction',
      () => _databaseHelper.insertPaymentTransaction(payment),
    ) ?? 0;
  }

  Future<void> insertPaymentTransactions(List<PaymentTransactionModel> payments) async {
    await _executeWithLogging(
      'insertPaymentTransactions',
      () => _databaseHelper.insertPaymentTransactions(payments),
    );
  }

  Future<List<PaymentTransactionModel>> getInvoicePayments(int invoiceId) async {
    return await _executeWithLogging(
      'getInvoicePayments',
      () => _databaseHelper.getInvoicePayments(invoiceId),
    ) ?? [];
  }

  Future<int> deleteInvoicePayments(int invoiceId) async {
    return await _executeWithLogging(
      'deleteInvoicePayments',
      () => _databaseHelper.deleteInvoicePayments(invoiceId),
    ) ?? 0;
  }

  // ========================================
  // SALES & REPORTING
  // ========================================

  Future<int> createInvoice({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    required List<PaymentTransactionModel> payments,
  }) async {
    return await _executeWithLogging(
      'createInvoice',
      () => _databaseHelper.createInvoice(
        invoice: invoice,
        items: items,
        payments: payments,
      ),
    ) ?? 0;
  }

  Future<Map<String, dynamic>?> getInvoiceFullDetails(int invoiceId) async {
    return await _executeWithLogging(
      'getInvoiceFullDetails',
      () => _databaseHelper.getInvoiceFullDetails(invoiceId),
    );
  }

  Future<List<InvoiceModel>> getFilteredInvoices({
    int limit = 20,
    int pageNo = 1,
    String? paymentMethodDetails,
    String? sortField,
    bool ascending = true,
    String? search,
  }) async {
    return await _executeWithLogging(
      'getFilteredInvoices',
      () => _databaseHelper.getFilteredInvoices(
        limit: limit,
        pageNo: pageNo,
        paymentMethodDetails: paymentMethodDetails,
        sortField: sortField,
        ascending: ascending,
        search: search,
      ),
    ) ?? [];
  }

  Future<DailySalesSummaryModel> getTodaySalesSummary() async {
    return await _executeWithLogging(
      'getTodaySalesSummary',
      () => _databaseHelper.getTodaySalesSummary(),
    ) ??
        DailySalesSummaryModel(
          totalInvoices: 0,
          totalSales: 0.0,
          totalTax: 0.0,
          totalDiscount: 0.0,
          totalPaid: 0.0,
        );
  }

  Future<DailySalesSummaryModel> getSalesSummary(
    String startDate,
    String endDate,
  ) async {
    return await _executeWithLogging(
      'getSalesSummary',
      () => _databaseHelper.getSalesSummary(startDate, endDate),
    ) ??
        DailySalesSummaryModel(
          totalInvoices: 0,
          totalSales: 0.0,
          totalTax: 0.0,
          totalDiscount: 0.0,
          totalPaid: 0.0,
        );
  }

  Future<List<SalesGraphModel>> getSalesGraph(
    String startDate,
    String endDate,
  ) async {
    return await _executeWithLogging(
      'getSalesGraph',
      () => _databaseHelper.getSalesGraph(startDate, endDate),
    ) ?? [];
  }

  Future<List<PaymentModeReportModel>> getPaymentModeTotals(
    String startDate,
    String endDate,
  ) async {
    return await _executeWithLogging(
      'getPaymentModeTotals',
      () => _databaseHelper.getPaymentModeTotals(startDate, endDate),
    ) ?? [];
  }

  Future<List<TopSellingItemModel>> getTopSellingItems(
    String startDate,
    String endDate,
  ) async {
    return await _executeWithLogging(
      'getTopSellingItems',
      () => _databaseHelper.getTopSellingItems(startDate, endDate),
    ) ?? [];
  }

  Future<List<SalesForecastModel>> getSalesForecast({
    required String startDate,
    required String endDate,
    int forecastDays = 7,
  }) async {
    return await _executeWithLogging(
      'getSalesForecast',
      () => _databaseHelper.getSalesForecast(
        startDate: startDate,
        endDate: endDate,
        forecastDays: forecastDays,
      ),
    ) ?? [];
  }

  Future<SalesDashboardModel> loadSalesDashboard() async {
    return await _executeWithLogging(
      'loadSalesDashboard',
      () => _databaseHelper.loadSalesDashboard(),
    ) ??
        SalesDashboardModel(
          todaySummary: DailySalesSummaryModel(
            totalInvoices: 0,
            totalSales: 0.0,
            totalTax: 0.0,
            totalDiscount: 0.0,
            totalPaid: 0.0,
          ),
          weeklyTrend: [],
          monthlyTrend: [],
          forecast: [],
          topItems: [],
          paymentModes: [],
        );
  }
}
