class AppRouteName {
  //HomeScreen
  static const String homeRoute = '/';
  //Initial Screen
  static const String splashRoute = '/splashScreen';
  //Authentication Screens After Splash Screen go to Login and form login to Registration Screen/loginViaPhoneNumberScreen
  static const String loginRoute = '/loginScreen';
  static const String registrationRoute = '/registrationScreen';
  static const String loginViaPhoneNumberRoute = '/loginViaPhoneNumberScreen';

  //From loginViaPhoneNumberScreen to otpScreen and from otpScreen to otpVerificationScreen
  static const String otpScreenRoute = '/otpScreen';
  static const String otpVerificationRoute = '/otpVerificationScreen';

  //After login or registration go to home screen and from home screen to all other screens via drawer
  static const String homeScreenRoute = '/homeScreen';

  //Drawer Screens from home screen
  static const String tableInfoScreenRoute = '/tableInfoScreen';
  static const String menuItemFullListScreenRoute =
      '/menuItemFullListScreenRoute';
  static const String menuCategoryFullListRoute = '/menuCategoryFullListScreen';
  static const String menuAllSubCategoryScreenRoute =
      '/menuAllSubCategoryScreen';
  static const String recipesListScreenRoute = '/RecipesListScreen';
  static const String inventoryListScreenRoute = '/inventoryListScreen';
  static const String purchaseListScreenRoute = '/purchaseListScreen';
  static const String reservationListScreenRoute = '/reservationListScreen';
  static const String customerListScreenRoute = '/customerListScreen';
  static const String orderListScreenRoute = '/orderListScreen';
  static const String invoiceListScreenRoute = '/invoiceListScreen';
  static const String invoicePaymentListScreenRoute =
      '/invoicePaymentListScreen';
  static const String invoicePaymentMethodListScreenRoute =
      '/invoicePaymentMethodListScreen';
  static const String expenditureListScreenRoute = '/expenditureListScreen';
  static const String reportScreenRoute = '/reportScreen';
  static const String staffManagementScreenRoute = '/staffManagementScreen';

  static const String settingsScreenRoute = '/settingsScreen';

  //From tableInfoScreen to addNewTableInfoScreen and updateTableInfoScreen
  static const String addNewTableInfoScreenRoute = '/addNewTableInfoScreen';
  static const String updateTableInfoScreenRoute = '/updateTableInfoScreen';

  //From menuItemFullListScreenRoute to addNewMenuItemScreenRoute and updateMenuItemScreenRoute
  static const String addNewMenuItemScreenRoute = '/addNewMenuItemScreenRoute';
  static const String updateMenuItemScreenRoute = '/updateMenuItemScreenRoute';

  //From menuCategoryFullListRoute to addNewMenuCategoryScreenRoute and updateMenuCategoryScreenRoute
  static const String addNewMenuCategoryScreenRoute =
      '/addNewMenuCategoryScreen';
  static const String updateMenuCategoryScreenRoute =
      '/updateMenuCategoryScreen';

  //From menuAllSubCategoryScreenRoute to addNewMenuSubCategoryScreenRoute and updateMenuSubCategoryScreenRoute
  static const String addNewMenuSubCategoryScreenRoute =
      '/addNewMenuSubCategoryScreen';
  static const String updateMenuSubCategoryScreenRoute =
      '/updateMenuSubCategoryScreen';

  //From inventoryListScreenRoute to inventoryAddOrEditItemRoute and inventoryPickerPageRoute
  static const String inventoryAddOrEditItemRoute =
      '/addOrEditInventoryItemScreen';
  static const String inventoryPickerPageRoute = '/inventoryPickerPage';

  //From purchaseListScreenRoute to purchaseAddOrEditItemRoute and purchasePickerPageRoute
  static const String purchaseAddOrEditItemRoute =
      '/addOrEditPurchaseItemScreen';
  static const String purchasePickerPageRoute = '/purchasePickerPage';

  //From reservationListScreenRoute to reservationAddOrEditItemRoute
  static const String reservationAddOrEditItemRoute =
      '/addOrEditReservationItemScreen';
  static const String reservationPickerPageRoute = '/reservationPickerPage';

  //From recipesListScreenRoute to recipesInfoScreenRoute or recipesBookmarkListScreenRoute
  static const String recipesInfoScreenRoute = '/RecipesInfoScreen';
  static const String recipesBookmarkListScreenRoute =
      '/RecipesBookmarkListScreen';

  //From orderListScreenRoute to orderInfoScreenRoute
  static const String orderInfoScreenRoute = '/orderInfoScreen';
  static const String orderPickerPageRoute = '/orderPickerPage';

  ///From homeScreenRoute/orderInfoScreenRoute to orderStatusUpdateScreenRoute
  static const String orderStatusUpdateScreenRoute = '/orderStatusUpdateScreen';

  //Form InvoiceScreenRoute to invoiceInfoScreenRoute
  static const String invoiceInfoScreenRoute = '/invoiceInfoScreen';
  static const String invoicePickerPageRoute = '/invoicePickerPage';
  static const String invoiceStatusUpdateScreenRoute =
      '/invoiceStatusUpdateScreen';
  static const String invoiceAddOrEditScreenRoute = '/addOrEditInvoiceScreen';
  static const String invoicePaymentScreenRoute = '/invoicePaymentScreen';
  static const String invoicePaymentInfoScreenRoute =
      '/invoicePaymentInfoScreen';
  static const String invoicePaymentAddOrEditScreenRoute =
      '/addOrEditInvoicePaymentScreen';
  static const String invoicePaymentStatusUpdateScreenRoute =
      '/invoicePaymentStatusUpdateScreen';
  static const String invoicePaymentPickerPageRoute =
      '/invoicePaymentPickerPage';
  // static const String invoicePaymentMethodListScreenRoute = '/invoicePaymentMethodListScreen';
  static const String addOrEditInvoicePaymentMethodScreenRoute =
      '/addOrEditInvoicePaymentMethodScreen';
  static const String invoicePaymentMethodInfoScreenRoute =
      '/invoicePaymentMethodInfoScreen';
  static const String invoicePaymentMethodPickerPageRoute =
      '/invoicePaymentMethodPickerPage';
  static const String invoicePaymentMethodStatusUpdateScreenRoute =
      '/invoicePaymentMethodStatusUpdateScreen';
  static const String invoicePaymentMethodDeleteScreenRoute =
      '/invoicePaymentMethodDeleteScreen';
  static const String invoicePaymentMethodRestoreScreenRoute =
      '/invoicePaymentMethodRestoreScreen';
  static const String invoicePaymentMethodArchiveScreenRoute =
      '/invoicePaymentMethodArchiveScreen';
  static const String invoicePaymentMethodUnarchiveScreenRoute =
      '/invoicePaymentMethodUnarchiveScreen';
  static const String invoicePaymentMethodTrashScreenRoute =
      '/invoicePaymentMethodTrashScreen';
  static const String invoicePaymentMethodUntrashScreenRoute =
      '/invoicePaymentMethodUntrashScreen';
  static const String invoicePaymentMethodDeleteConfirmationScreenRoute =
      '/invoicePaymentMethodDeleteConfirmationScreen';
  static const String invoicePaymentMethodRestoreConfirmationScreenRoute =
      '/invoicePaymentMethodRestoreConfirmationScreen';
  static const String invoicePaymentMethodArchiveConfirmationScreenRoute =
      '/invoicePaymentMethodArchiveConfirmationScreen';
  static const String invoicePaymentMethodUnarchiveConfirmationScreenRoute =
      '/invoicePaymentMethodUnarchiveConfirmationScreen';
  static const String invoicePaymentMethodTrashConfirmationScreenRoute =
      '/invoicePaymentMethodTrashConfirmationScreen';
  static const String invoicePaymentMethodUntrashConfirmationScreenRoute =
      '/invoicePaymentMethodUntrashConfirmationScreen';
  static const String invoicePaymentMethodDeleteSuccessScreenRoute =
      '/invoicePaymentMethodDeleteSuccessScreen';
  static const String invoicePaymentMethodRestoreSuccessScreenRoute =
      '/invoicePaymentMethodRestoreSuccessScreen';
  static const String invoicePaymentMethodArchiveSuccessScreenRoute =
      '/invoicePaymentMethodArchiveSuccessScreen';
  static const String invoicePaymentMethodUnarchiveSuccessScreenRoute =
      '/invoicePaymentMethodUnarchiveSuccessScreen';
  static const String invoicePaymentMethodTrashSuccessScreenRoute =
      '/invoicePaymentMethodTrashSuccessScreen';
  static const String invoicePaymentMethodUntrashSuccessScreenRoute =
      '/invoicePaymentMethodUntrashSuccessScreen';
  static const String invoicePaymentMethodDeleteFailureScreenRoute =
      '/invoicePaymentMethodDeleteFailureScreen';
  static const String invoicePaymentMethodRestoreFailureScreenRoute =
      '/invoicePaymentMethodRestoreFailureScreen';
  static const String invoicePaymentMethodArchiveFailureScreenRoute =
      '/invoicePaymentMethodArchiveFailureScreen';
  static const String invoicePaymentMethodUnarchiveFailureScreenRoute =
      '/invoicePaymentMethodUnarchiveFailureScreen';
  static const String invoicePaymentMethodTrashFailureScreenRoute =
      '/invoicePaymentMethodTrashFailureScreen';
  static const String invoicePaymentMethodUntrashFailureScreenRoute =
      '/invoicePaymentMethodUntrashFailureScreen';
  static const String invoicePaymentMethodStatusUpdateSuccessScreenRoute =
      '/invoicePaymentMethodStatusUpdateSuccessScreen';
  static const String invoicePaymentMethodStatusUpdateFailureScreenRoute =
      '/invoicePaymentMethodStatusUpdateFailureScreen';
  static const String invoicePaymentMethodStatusUpdateConfirmationScreenRoute =
      '/invoicePaymentMethodStatusUpdateConfirmationScreen';
  static const String
  invoicePaymentMethodStatusUpdateSuccessConfirmationScreenRoute =
      '/invoicePaymentMethodStatusUpdateSuccessConfirmationScreenRoute';
  static const String
  invoicePaymentMethodStatusUpdateFailureConfirmationScreenRoute =
      '/invoicePaymentMethodStatusUpdateFailureConfirmationScreenRoute';

  //From reportScreenRoute to reportDetailScreenRoute
  static const String reportDetailScreenRoute = '/reportDetailScreen';
  //From reportDetailScreenRoute to reportFilterScreenRoute
  static const String reportFilterScreenRoute = '/reportFilterScreen';
  //From reportFilterScreenRoute to reportPickerPageRoute
  static const String reportPickerPageRoute = '/reportPickerPage';
  //From reportPickerPageRoute to reportDetailScreenRoute
  static const String reportInfoScreenRoute = '/reportDetailScreen';

  ///expenditureListScreenRoute to expenditureAddOrEditScreenRoute
  static const String expenditureAddOrEditScreenRoute =
      '/addOrEditExpenditureScreen';
  //From expenditureListScreenRoute to expenditureInfoScreenRoute
  static const String expenditureInfoScreenRoute = '/expenditureInfoScreen';

  //From staffManagementScreen 3 top tab Employee List, Employee Attendance, Employee Leave
  static const String employeeListScreenRoute = '/employeeListScreen';
  static const String employeeAttendanceScreenRoute =
      '/employeeAttendanceScreen';
  static const String employeeLeaveScreenRoute = '/employeeLeaveScreen';

  ///From employeeListScreenRoute to employeeInfoScreenRoute
  static const String employeeInfoScreenRoute = '/employeeInfoScreen';
  //From employeeListScreenRoute to addOrEditEmployeeScreenRoute
  static const String addOrEditEmployeeScreenRoute = '/addOrEditEmployeeScreen';

  //From employeeAttendanceScreenRoute to employeeAttendanceInfoScreenRoute
  static const String employeeAttendanceInfoScreenRoute =
      '/employeeAttendanceInfoScreen';
  //From employeeAttendanceScreenRoute or employeeAttendanceInfoScreenRoute to addOrEditEmployeeAttendanceScreenRoute
  static const String addOrEditEmployeeAttendanceScreenRoute =
      '/addOrEditEmployeeAttendanceScreen';

  ///From employeeLeaveScreenRoute to employeeLeaveInfoScreenRoute
  static const String employeeLeaveInfoScreenRoute = '/employeeLeaveInfoScreen';
  //From employeeLeaveScreenRoute or employeeLeaveInfoScreenRoute to addOrEditEmployeeLeaveScreenRoute
  static const String addOrEditEmployeeLeaveScreenRoute =
      '/addOrEditEmployeeLeaveScreen';

  ///From CustomerListScreenRoute to customerInfoScreenRoute
  static const String customerInfoScreenRoute = '/customerInfoScreen';
  //From CustomerListScreenRoute or customerInfoScreenRoute to addOrEditCustomerScreenRoute
  static const String addOrEditCustomerScreenRoute = '/addOrEditCustomerScreen';
  static const String customerPickerPageRoute = '/customerPickerPage';
}
