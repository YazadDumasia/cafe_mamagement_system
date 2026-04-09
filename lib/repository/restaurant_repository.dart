import '../database/database_helper.dart' as dh;
import '../utlis/utlis.dart' as cs show Constants;

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
    Future<T> Function() operation, {
    bool trackExecutionTime = false,
  }) async {
    final buildmode = await cs.Constants.getCurrentPlatformBuildMode();
    if (buildmode == 'release') {
      return await operation();
    } else {
      final stopwatch = trackExecutionTime ? (Stopwatch()..start()) : null;

      try {
        final result = await operation();

        if (stopwatch != null) {
          stopwatch.stop();
          cs.Constants.debugLog(
            RestaurantRepository,
            "Execution time:$methodName:${stopwatch.elapsedMilliseconds} ms",
          );
        }

        return result;
      } catch (e) {
        if (stopwatch != null) {
          stopwatch.stop();
          cs.Constants.debugLog(
            RestaurantRepository,
            "Error in $methodName:$e, time:${stopwatch.elapsedMilliseconds} ms",
          );
        } else {
          cs.Constants.debugLog(
            RestaurantRepository,
            'Error in $methodName: $e',
          );
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
}
