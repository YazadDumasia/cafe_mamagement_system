import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/recipe/recipe_model.dart';
import '../database_tables.dart';

class RecipesDao {
  final Database db;

  RecipesDao(this.db);

  Future<void> insertRecipes(List<RecipeModel> recipes) async {
    const int batchSize = 10;
    final Batch batch = db.batch();

    for (int i = 0; i < recipes.length; i += batchSize) {
      final chunk = recipes.sublist(
        i,
        i + batchSize > recipes.length ? recipes.length : i + batchSize,
      );

      for (final recipe in chunk) {
        batch.insert(
          DatabaseTables.recipeModelTable,
          recipe.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      batch.commit(noResult: true);
      debugPrint('Inserted batch ${i ~/ batchSize + 1}');
    }
  }

  /// Get all Bookmarked recipes
  Future<List<RecipeModel>?> getBookmarkedRecipes() async {
    final List<Map<String, dynamic>?> maps = await db.query(
      DatabaseTables.recipeModelTable,
      where: 'isBookmark = ?',
      whereArgs: <Object?>[1],
    ); // Filter where isBookmark column equals 1

    if (maps.isEmpty) {
      return <RecipeModel>[];
    } else {
      return List.generate(
        maps.length,
        (index) => RecipeModel.fromJson(maps[index] ?? {}),
      );
    }
  }

  ///Insert Recipes in Chunks
  Future<void> insertRecipesChunked(List<RecipeModel>? recipes) async {
    if (recipes == null || recipes.isEmpty) {
      return;
    }

    // Estimate average record size from a sample (first 100 records)
    final avgSize = recipes.length > 100
        ? utf8
                  .encode(
                    jsonEncode(
                      recipes.take(100).map((e) => e.toJson()).toList(),
                    ),
                  )
                  .length ~/
              100
        : 1200; // fallback for smaller sets

    const maxBatchBytes = 512 * 1024; // max ~512 KB per chunk
    final estimatedChunkSize = (maxBatchBytes / avgSize).floor();

    final chunkSize = estimatedChunkSize.clamp(50, 500);
    debugPrint('Chunk size: $chunkSize (avg $avgSize bytes)');

    for (int i = 0; i < recipes.length; i += chunkSize) {
      final chunk = recipes.skip(i).take(chunkSize).toList();
      final batch = db.batch();

      for (final recipe in chunk) {
        batch.insert(
          DatabaseTables.recipeModelTable,
          recipe.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    }
  }

  ///Update Recipes
  Future<int?> updateRecipe(RecipeModel recipe) async {
    final Batch batch = db.batch();
    batch.update(
      DatabaseTables.recipeModelTable,
      recipe.toJson(),
      where: 'recipe_id = ?',
      whereArgs: <Object?>[recipe.id],
    );

    final List<Object?> results = await batch.commit();
    return (results.isNotEmpty && results[0] is int) ? results as int : null;
  }

  ///Delete Recipes
  Future<int?> deleteRecipe({int? id}) async {
    if (id == null) return 0;
    final Batch batch = db.batch();
    batch.delete(
      DatabaseTables.recipeModelTable,
      where: 'recipe_id = ?',
      whereArgs: <Object?>[id],
    );

    final List<Object?> results = await batch.commit();
    return (results.isNotEmpty && results[0] is int) ? results as int : null;
  }

  ///Delete Recipes in Batch
  Future<List<int>> deleteRecipesBatch(List<int> ids) async {
    if (ids.isEmpty) return [];

    final Batch batch = db.batch();

    for (final int id in ids) {
      batch.delete(
        DatabaseTables.recipeModelTable,
        where: 'recipe_id = ?',
        whereArgs: <Object?>[id],
      );
    }

    final List<Object?> results = await batch.commit();
    return results.map((res) => res is int ? res : 0).toList();
  }

  /// Get all recipes
  Future<List<RecipeModel>?> getRecipes({int chunkSize = 200}) async {
    final List<RecipeModel> allRecipes = [];

    // Get total count
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${DatabaseTables.recipeModelTable}',
    );
    final totalCount = Sqflite.firstIntValue(countResult) ?? 0;

    // Process in chunks
    for (int offset = 0; offset < totalCount; offset += chunkSize) {
      final List<Map<String, dynamic>> chunk = await db.query(
        DatabaseTables.recipeModelTable,
        limit: chunkSize,
        offset: offset,
      );

      final List<RecipeModel> chunkModels = chunk.map((map) {
        return RecipeModel(
          recipeID: map['recipe_id'] as int?,
          id: map['id'] as int?,
          recipeName: map['recipe_name'] as String?,
          translatedRecipeName: map['translated_recipe_name'] as String?,
          recipeIngredients: map['recipe_ingredients'] as String?,
          recipeTranslatedIngredients:
              map['recipe_translated_ingredients'] as String?,
          recipePreparationTimeInMins:
              map['recipe_preparation_time_in_mins'] as int?,
          recipeCookingTimeInMins: map['recipe_cooking_time_in_mins'] as int?,
          recipeTotalTimeInMins: map['recipe_total_time_in_mins'] as int?,
          recipeServings: map['recipe_servings'] as int?,
          recipeCuisine: map['recipe_cuisine'] as String?,
          recipeCourse: map['recipe_course'] as String?,
          recipeDiet: map['recipe_diet'] as String?,
          recipeInstructions: map['recipe_instructions'] as String?,
          recipeTranslatedInstructions:
              map['recipe_translated_instructions'] as String?,
          recipeReferenceUrl: map['recipe_reference_url'] as String?,
          isBookmark: (map['isBookmark'] as int?) == 1,
        );
      }).toList();

      allRecipes.addAll(chunkModels);
      debugPrint('Loaded batch ${offset ~/ chunkSize + 1}');
    }

    return allRecipes;
  }

  /// Extract ingredients from recipe ingredients string
  Future<void> processRecipeIngredients({
    int chunkSize = 200,
    void Function(double progress)? onProgress,
  }) async {
    // Get total count of recipes
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${DatabaseTables.recipeModelTable}',
    );
    final totalCount = Sqflite.firstIntValue(countResult) ?? 0;

    if (totalCount == 0) {
      onProgress?.call(1.0); // 100% done - nothing to process
      return;
    }

    int processedCount = 0;

    // Process all recipes in chunks to avoid large memory usage
    for (int offset = 0; offset < totalCount; offset += chunkSize) {
      final List<Map<String, Object?>> chunk = await db.query(
        DatabaseTables.recipeModelTable,
        limit: chunkSize,
        offset: offset,
      );

      final List<RecipeModel> recipesChunk = chunk.map((map) {
        return RecipeModel(
          recipeID: map['recipe_id'] as int?,
          id: map['id'] as int?,
          recipeName: map['recipe_name'] as String?,
          translatedRecipeName: map['translated_recipe_name'] as String?,
          recipeIngredients: map['recipe_ingredients'] as String?,
          recipeTranslatedIngredients:
              map['recipe_translated_ingredients'] as String?,
          recipePreparationTimeInMins:
              map['recipe_preparation_time_in_mins'] as int?,
          recipeCookingTimeInMins: map['recipe_cooking_time_in_mins'] as int?,
          recipeTotalTimeInMins: map['recipe_total_time_in_mins'] as int?,
          recipeServings: map['recipe_servings'] as int?,
          recipeCuisine: map['recipe_cuisine'] as String?,
          recipeCourse: map['recipe_course'] as String?,
          recipeDiet: map['recipe_diet'] as String?,
          recipeInstructions: map['recipe_instructions'] as String?,
          recipeTranslatedInstructions:
              map['recipe_translated_instructions'] as String?,
          recipeReferenceUrl: map['recipe_reference_url'] as String?,
          isBookmark: (map['isBookmark'] as int?) == 1,
        );
      }).toList();

      // Process batch of recipes within a transaction for atomicity
      await db.transaction((Transaction txn) async {
        final Batch batch = txn.batch();

        for (final recipe in recipesChunk) {
          if (recipe.recipeIngredients == null ||
              recipe.recipeIngredients!.isEmpty) {
            continue;
          }

          final List<String> ingredients = extractIngredients(
            recipe.recipeIngredients!,
          );

          if (ingredients.isEmpty) continue;

          final existingRows = await txn.query(
            DatabaseTables.ingredientsRecipeModelTable,
            columns: ['ingredient_name', 'counter', 'recipe_ids'],
            where:
                'ingredient_name IN (${List.filled(ingredients.length, '?').join(',')})',
            whereArgs: ingredients,
          );

          final existingMap = {
            for (var row in existingRows)
              (row['ingredient_name'] as String): row,
          };

          for (final ingredient in ingredients) {
            if (existingMap.containsKey(ingredient)) {
              final existingData = existingMap[ingredient]!;

              final int currentCounter = (existingData['counter'] as int?) ?? 0;

              final List<dynamic> recipeIds = jsonDecode(
                existingData['recipe_ids'] as String? ?? '[]',
              );

              if (!recipeIds.contains(recipe.id)) {
                recipeIds.add(recipe.id);
              }

              batch.update(
                DatabaseTables.ingredientsRecipeModelTable,
                {
                  'counter': currentCounter + 1,
                  'recipe_ids': jsonEncode(recipeIds),
                },
                where: 'ingredient_name = ?',
                whereArgs: [ingredient],
              );
            } else {
              batch.insert(DatabaseTables.ingredientsRecipeModelTable, {
                'ingredient_name': ingredient,
                'recipe_ids': jsonEncode([recipe.id]),
                'counter': 1,
              });
            }
          }
        }

        await batch.commit(noResult: true);
      });

      // Update processed count and call progress callback
      processedCount += recipesChunk.length;
      double progress = processedCount / totalCount;
      onProgress?.call(progress);
    }

    // Ensure progress is 100% at the end
    onProgress?.call(1.0);
  }

  /// Extract ingredients from recipe ingredients string
  Future<void> processSingleRecipeIngredients(RecipeModel recipe) async {
    if (recipe.recipeIngredients == null || recipe.recipeIngredients!.isEmpty) {
      return;
    }

    final List<String> ingredients = extractIngredients(
      recipe.recipeIngredients!,
    );
    if (ingredients.isEmpty) return;

    try {
      await db.transaction((Transaction txn) async {
        final Batch batch = txn.batch();

        final existingRows = await txn.query(
          DatabaseTables.ingredientsRecipeModelTable,
          columns: ['ingredient_name', 'counter', 'recipe_ids'],
          where:
              'ingredient_name IN (${List.filled(ingredients.length, '?').join(',')})',
          whereArgs: ingredients,
        );

        final Map<String, Map<String, Object?>> existingMap = {
          for (var row in existingRows) (row['ingredient_name'] as String): row,
        };

        for (final ingredient in ingredients) {
          if (existingMap.containsKey(ingredient)) {
            final existingData = existingMap[ingredient]!;
            final int currentCount = (existingData['counter'] as int?) ?? 0;
            final List<dynamic> recipeIds = jsonDecode(
              existingData['recipe_ids'] as String? ?? '[]',
            );
            if (!recipeIds.contains(recipe.id)) {
              recipeIds.add(recipe.id);
            }

            batch.update(
              DatabaseTables.ingredientsRecipeModelTable,
              {
                'counter': currentCount + 1,
                'recipe_ids': jsonEncode(recipeIds),
              },
              where: 'ingredient_name = ?',
              whereArgs: [ingredient],
            );
          } else {
            batch.insert(DatabaseTables.ingredientsRecipeModelTable, {
              'ingredient_name': ingredient,
              'recipe_ids': jsonEncode([recipe.id]),
              'counter': 1,
            });
          }
        }

        await batch.commit(noResult: true);
      });
    } catch (e, st) {
      debugPrint(
        'Failed to process single recipe ingredients for recipe ${recipe.id}. Error: $e',
      );
      debugPrintStack(stackTrace: st);
      // Handle error accordingly (e.g., notify, retry, etc.)
    }
  }

  /// Extract ingredients from raw ingredients string.
  List<String> extractIngredients(String rawIngredients) {
    if (rawIngredients.isEmpty) return [];

    // List of measurement units we want to remove when leading the ingredient
    final List<String> measurementUnits = [
      'cup',
      'cups',
      'tablespoon',
      'tablespoons',
      'teaspoon',
      'teaspoons',
      'tbsp',
      'tsp',
      'gram',
      'grams',
      'kg',
      'ml',
      'liter',
      'liters',
      'oz',
      'ounce',
      'ounces',
      'pound',
      'pounds',
      'gallon',
      'gallons',
      'dash',
      'pinch',
    ];

    // Regex to detect leading quantity + units at start of ingredient string
    final RegExp leadingQtyRegex = RegExp(
      r'^\s*\d+(\.\d+)?\s*(?:' +
          measurementUnits.map((u) => RegExp.escape(u)).join('|') +
          r')?\b',
      caseSensitive: false,
    );

    return rawIngredients
        .split(',')
        .map((rawIng) {
          String ing = rawIng.trim();

          // Remove leading quantity and measurement unit if exists
          ing = ing.replaceFirst(leadingQtyRegex, '').trim();

          // Remove leading numbers only (if any remain)
          ing = ing.replaceFirst(RegExp(r'^\d+\s*'), '').trim();

          // Just a final trim
          return ing;
        })
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Searches and returns a list of ingredients matching the search term, case-insensitively, or null if the term is empty.
  Future<List<Map<String, dynamic>>?> searchIngredients(
    String? searchTerm,
  ) async {
    // Check if searchTerm is null or empty
    if (searchTerm == null || searchTerm.trim().isEmpty) {
      return null; // Return an empty list if the search term is null or empty
    }

    // Normalize search term
    final String queryTerm = '%${searchTerm.trim().toLowerCase()}%';

    // Query the ingredients table
    final List<Map<String, dynamic>> results = await db.query(
      DatabaseTables.ingredientsRecipeModelTable,
      where: 'LOWER(ingredient_name) LIKE ?',
      whereArgs: <Object?>[queryTerm],
      orderBy: 'ingredient_name ASC',
    );

    return results;
  }

  /// Get all ingredients
  Future<List<Map<String, dynamic>>?> fetchAllIngredients() async {
    // Query to fetch all ingredients
    final List<Map<String, dynamic>> results = await db.query(
      DatabaseTables.ingredientsRecipeModelTable,
      orderBy: 'ingredient_name ASC',
    );

    return results;
  }
}
