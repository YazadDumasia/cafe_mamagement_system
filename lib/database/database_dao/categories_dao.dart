import 'package:sqflite/sqflite.dart';
import '../../model/category.dart';
import '../../model/sub_category.dart';
import '../../utlis/utlis.dart';
import '../database_tables.dart';
import '../database_helper.dart';

class CategoriesDao {
  final Database db;

  CategoriesDao(this.db);

  // Category CRUD operations

  /// Add a category
  Future<int?> addCategory(Category category) async {
    return await db.transaction<int?>((Transaction txn) async {
      // Use a subquery to get the maximum sortOrderIndex
      final List<Map<String, dynamic>>
      maxSortRecordIndexResult = await txn.rawQuery(
        'SELECT COALESCE(MAX(position), -1) AS maxIndex FROM ${DatabaseTables.categoriesTable}',
      );

      final int maxSortRecordIndex =
          Sqflite.firstIntValue(maxSortRecordIndexResult) ?? -1;

      // Automatically generate sortOrderIndex based on the last position
      category.position = maxSortRecordIndex + 1;

      final Category? model = await getCategoryBasedOnName(name: category.name);
      if (model == null) {
        return await txn.insert(
          DatabaseTables.categoriesTable,
          category.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      return null;
    });
  }

  /// Get all categories
  Future<List<Category>?> getCategories() async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.categoriesTable,
      orderBy: 'position ASC', // Order by the 'name' column in ascending order
    );

    return List.generate(maps.length, (i) {
      return Category.fromJson(maps[i]);
    });
  }

  /// Update a category
  Future<int?> updateCategory(Category category) async {
    Constants.debugLog(DatabaseHelper, 'updateCategory: ${category.toJson()}');

    return await db.transaction<int?>((Transaction txn) async {
      try {
        final Batch batch = txn.batch();
        batch.update(
          DatabaseTables.categoriesTable,
          category.toJson(),
          where: 'id = ?',
          whereArgs: <Object?>[category.id],
        );

        final List<Object?> results = await batch.commit();
        return (results.isNotEmpty && results[0] is int)
            ? results[0] as int
            : null;
      } catch (e) {
        Constants.debugLog(DatabaseHelper, 'updateCategory:Error: $e');
        return null;
      }
    });
  }

  /// Get a category based on its name.
  Future<Category?> getCategoryBasedOnName({String? name}) async {
    if (name != null && name.isNotEmpty) {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.categoriesTable,
        where: 'name = ?',
        whereArgs: <Object?>[name],
        orderBy: 'name ASC',
        limit: 1, // Limit the result to one record
      );

      if (maps.isEmpty) {
        return null;
      }

      // Return the first (and only) record as a single object
      return Category.fromJson(maps.first);
    } else {
      return null;
    }
  }

  /// Get a category based on its ID.
  Future<Category?> getCategoryBasedOnCategoryId({
    required int? categoryId,
  }) async {
    if (categoryId == null) {
      return null;
    } else {
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseTables.categoriesTable,
        where: 'id = ?',
        whereArgs: <Object?>[categoryId],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return Category.fromJson(maps.first);
    }
  }

  /// Delete a category
  Future<int?> deleteCategory(Category? model) async {
    // Start a transaction to ensure atomicity
    return db.transaction<int?>((Transaction txn) async {
      final int sortRecordIndexToDelete = model!.position ?? 0;

      // Step 1: Delete the item from the database
      final int rowsAffected = await txn.delete(
        DatabaseTables.categoriesTable,
        where: 'id = ?',
        whereArgs: <Object?>[model.id!],
      );

      // Step 2: Update sortOrderIndex for items with a higher index in batches
      const int batchSize =
          100; // Adjust this size based on performance testing

      // ignore: unused_local_variable
      int totalRowsUpdated = 0;

      // Calculate how many rows need to be updated
      final List<Map<String, Object?>> totalRowsToUpdate = await txn.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseTables.categoriesTable} WHERE position > ?',
        <Object?>[sortRecordIndexToDelete],
      );

      // Extracting the number of rows to update correctly
      int rowsToUpdate = totalRowsToUpdate.isNotEmpty
          ? (totalRowsToUpdate[0]['COUNT(*)'] as int?) ?? 0
          : 0;

      // Perform batched updates
      while (rowsToUpdate > 0) {
        // Calculate the number of rows to update in this batch
        final int currentBatchSize = (rowsToUpdate < batchSize)
            ? rowsToUpdate
            : batchSize;

        // Update the sortOrderIndex for the current batch
        await txn.rawUpdate(
          'UPDATE ${DatabaseTables.categoriesTable} SET position = position - 1 '
          'WHERE position > ? LIMIT ?',
          <Object?>[sortRecordIndexToDelete, currentBatchSize],
        );

        // Decrement the remaining rows to update
        rowsToUpdate -= currentBatchSize;
        totalRowsUpdated += currentBatchSize;
      }

      // Return the result of the transaction (number of rows deleted)
      return rowsAffected;
    });
  }

  // Subcategory CRUD operations

  ///Create a new subcategory
  Future<int> createSubcategory(SubCategory subcategory) async {
    return await db.transaction<int>((Transaction txn) async {
      return await txn.insert(
        DatabaseTables.subcategoriesTable,
        subcategory.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  /// Get all subcategories
  Future<List<SubCategory>?> getSubcategories() async {
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.subcategoriesTable,
      orderBy: 'position ASC',
    );
    if (maps.isNotEmpty) {
      return List.generate(maps.length, (i) {
        return SubCategory.fromJson(maps[i]);
      });
    } else {
      return null;
    }
  }

  /// Get a subcategory based on its ID.
  Future<List<SubCategory>?> getSubcategoryBaseCategoryId(
    int categoryId,
  ) async {
    final List<Map<String, dynamic>?> maps = await db.query(
      DatabaseTables.subcategoriesTable,
      where: 'categoryId = ?',
      whereArgs: <Object?>[categoryId],
      orderBy: 'position ASC',
    );

    if (maps.isNotEmpty) {
      return List.generate(maps.length, (i) {
        return SubCategory.fromJson(maps[i]!);
      });
    } else {
      return null;
    }
  }

  /// Update a subcategory
  Future<int?> updateSubcategory(SubCategory subcategory) async {
    return await db.transaction<int?>((Transaction txn) async {
      final Map<String, dynamic> data = subcategory.toJson();

      final Batch batch = txn.batch();
      batch.update(
        DatabaseTables.subcategoriesTable,
        data,
        where: 'id = ?',
        whereArgs: <Object?>[subcategory.id],
      );

      final List<Object?> results = await batch.commit();
      return (results.isNotEmpty && results[0] is int) ? results[0] as int : null;
    });
  }

  /// Delete a subcategory
  Future<int?> deleteSubcategory(int id) async {
    return await db.transaction<int?>((Transaction txn) async {
      try {
        final Batch batch = txn.batch();
        batch.delete(
          DatabaseTables.subcategoriesTable,
          where: 'id = ?',
          whereArgs: <Object?>[id],
        );

        final List<Object?> results = await batch.commit();
        return (results.isNotEmpty && results[0] is int)
            ? results[0] as int
            : null;
      } catch (e, stacktrace) {
        // Log the error for debugging
        Constants.debugLog(
          DatabaseHelper,
          'deleteSubcategory:Error: $e stacktrace: $stacktrace',
        );
        return null; // Return null or custom error code as needed
      }
    });
  }

  /// Delete all subcategories base on categoryId in batches
  Future<int?> deleteAllSubcategoryBasedOnCategoryId({int? categoryId}) async {
    if (categoryId == null) return null;

    try {
      return await db.transaction<int?>((txn) async {
        final Batch batch = txn.batch();
        batch.delete(
          DatabaseTables.subcategoriesTable,
          where: 'categoryId = ?',
          whereArgs: <Object?>[categoryId],
        );
        final List<Object?> results = await batch.commit(noResult: false);
        if (results.isNotEmpty && results[0] is int) {
          return results[0] as int; // exact count of rows deleted
        }
        return 0; // no rows deleted
      });
    } catch (e, stacktrace) {
      Constants.debugLog(
        DatabaseHelper,
        'deleteAllSubcategoryBasedOnCategoryId:Error: $e stacktrace: $stacktrace',
      );
      return null;
    }
  }

  ///Insert a subcategories in batch with the specified ID from the database.
  Future<void> insertSubCategoriesForCategoryId({
    required int? categoryId,
    required List<SubCategory> subCategories,
  }) async {
    if (categoryId == null || subCategories.isEmpty) return;

    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();

      for (final subCategory in subCategories) {
        batch.insert(
          DatabaseTables.subcategoriesTable,
          subCategory.toJson(),
          conflictAlgorithm:
              ConflictAlgorithm.replace, // prevents duplicate errors
        );
      }

      await batch.commit(noResult: true);
    });
  }
}
