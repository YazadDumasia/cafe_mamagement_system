class IngredientsRecipeModel {
  IngredientsRecipeModel({
    this.ingredientID,
    this.recipeID,
    this.ingredientName,
    this.counter,
  });

  // Factory method to create an IngredientModel from a Map (from JSON or DB query result)
  factory IngredientsRecipeModel.fromJson(Map<String, dynamic> json) =>
      IngredientsRecipeModel(
        ingredientID: json['ingredient_id'],
        recipeID: json['recipe_id'],
        ingredientName: json['ingredient_name'],
        counter: json['counter'],
      );
  int? ingredientID;
  int? recipeID;
  String? ingredientName;
  int? counter;

  // CopyWith method to easily create a modified copy of an IngredientModel
  IngredientsRecipeModel copyWith({
    int? ingredientID,
    int? recipeID,
    String? ingredientName,
    String? translatedIngredientName,
    int? counter,
  }) => IngredientsRecipeModel(
    ingredientID: ingredientID ?? this.ingredientID,
    recipeID: recipeID ?? this.recipeID,
    ingredientName: ingredientName ?? this.ingredientName,
    counter: counter ?? this.counter,
  );

  // Method to convert the IngredientModel to a Map (for JSON or DB insertion)
  Map<String, dynamic> toJson() => <String, dynamic>{
    'ingredient_id': ingredientID,
    'recipe_id': recipeID,
    'ingredient_name': ingredientName,
    'counter': counter,
  };

  @override
  String toString() {
    return 'IngredientsRecipeModel{ingredientID: $ingredientID, recipeID: $recipeID, ingredientName: $ingredientName, counter: $counter}';
  }
}
