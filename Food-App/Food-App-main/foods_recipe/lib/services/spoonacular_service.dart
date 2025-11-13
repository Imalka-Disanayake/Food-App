import 'dart:convert';
import 'package:http/http.dart' as http;

class SpoonacularService {
  static const String _apiKey = '46b27efe507242ceadf84b77a3981d3b';
  static const String _baseUrl = 'https://api.spoonacular.com';

  // Fallback mock data when API fails
  List<Map<String, dynamic>> _getMockRecipes() {
    return [
      {
        'id': 1,
        'title': 'Spaghetti Carbonara',
        'image': 'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=400',
        'readyInMinutes': 30,
        'servings': 4,
        'summary': 'A classic Italian pasta dish made with eggs, cheese, pancetta, and black pepper. Creamy and delicious!',
        'dishTypes': ['lunch', 'main course', 'dinner'],
        'vegetarian': false,
        'vegan': false,
        'glutenFree': false,
        'dairyFree': false,
        'healthScore': 45.0,
        'ingredients': [
          {'name': 'Spaghetti', 'amount': '400', 'unit': 'g'},
          {'name': 'Pancetta', 'amount': '200', 'unit': 'g'},
          {'name': 'Eggs', 'amount': '4', 'unit': 'whole'},
          {'name': 'Parmesan Cheese', 'amount': '100', 'unit': 'g'},
          {'name': 'Black Pepper', 'amount': '1', 'unit': 'tsp'},
          {'name': 'Salt', 'amount': '1', 'unit': 'tsp'},
        ],
        'nutrition': {
          'calories': '550 kcal',
          'protein': '28g',
          'carbs': '65g',
          'fat': '22g',
        },
      },
      {
        'id': 2,
        'title': 'Chicken Curry',
        'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
        'readyInMinutes': 45,
        'servings': 6,
        'summary': 'A flavorful and aromatic curry with tender chicken pieces cooked in a rich, spicy sauce with coconut milk.',
        'dishTypes': ['lunch', 'main course', 'dinner'],
        'vegetarian': false,
        'vegan': false,
        'glutenFree': true,
        'dairyFree': true,
        'healthScore': 68.0,
        'ingredients': [
          {'name': 'Chicken Breast', 'amount': '800', 'unit': 'g'},
          {'name': 'Coconut Milk', 'amount': '400', 'unit': 'ml'},
          {'name': 'Onions', 'amount': '2', 'unit': 'whole'},
          {'name': 'Tomatoes', 'amount': '3', 'unit': 'whole'},
          {'name': 'Curry Powder', 'amount': '3', 'unit': 'tbsp'},
          {'name': 'Garlic', 'amount': '4', 'unit': 'cloves'},
          {'name': 'Ginger', 'amount': '2', 'unit': 'tbsp'},
          {'name': 'Vegetable Oil', 'amount': '2', 'unit': 'tbsp'},
        ],
        'nutrition': {
          'calories': '420 kcal',
          'protein': '35g',
          'carbs': '18g',
          'fat': '25g',
        },
      },
      {
        'id': 3,
        'title': 'Caesar Salad',
        'image': 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400',
        'readyInMinutes': 15,
        'servings': 2,
        'summary': 'Fresh romaine lettuce with crispy croutons, parmesan cheese, and classic Caesar dressing.',
        'dishTypes': ['salad', 'side dish', 'lunch'],
        'vegetarian': true,
        'vegan': false,
        'glutenFree': false,
        'dairyFree': false,
        'healthScore': 55.0,
        'ingredients': [
          {'name': 'Romaine Lettuce', 'amount': '1', 'unit': 'head'},
          {'name': 'Croutons', 'amount': '1', 'unit': 'cup'},
          {'name': 'Parmesan Cheese', 'amount': '50', 'unit': 'g'},
          {'name': 'Caesar Dressing', 'amount': '4', 'unit': 'tbsp'},
          {'name': 'Lemon Juice', 'amount': '1', 'unit': 'tbsp'},
        ],
        'nutrition': {
          'calories': '320 kcal',
          'protein': '12g',
          'carbs': '25g',
          'fat': '20g',
        },
      },
      {
        'id': 4,
        'title': 'Margherita Pizza',
        'image': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
        'readyInMinutes': 25,
        'servings': 4,
        'summary': 'Classic Italian pizza topped with fresh tomatoes, mozzarella cheese, and basil leaves.',
        'dishTypes': ['lunch', 'main course', 'dinner'],
        'vegetarian': true,
        'vegan': false,
        'glutenFree': false,
        'dairyFree': false,
        'healthScore': 50.0,
        'ingredients': [
          {'name': 'Pizza Dough', 'amount': '500', 'unit': 'g'},
          {'name': 'Tomato Sauce', 'amount': '200', 'unit': 'ml'},
          {'name': 'Mozzarella Cheese', 'amount': '300', 'unit': 'g'},
          {'name': 'Fresh Basil', 'amount': '10', 'unit': 'leaves'},
          {'name': 'Olive Oil', 'amount': '2', 'unit': 'tbsp'},
          {'name': 'Salt', 'amount': '1', 'unit': 'tsp'},
        ],
        'nutrition': {
          'calories': '480 kcal',
          'protein': '18g',
          'carbs': '58g',
          'fat': '18g',
        },
      },
      {
        'id': 5,
        'title': 'Chocolate Cake',
        'image': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400',
        'readyInMinutes': 60,
        'servings': 8,
        'summary': 'Rich and moist chocolate cake with layers of chocolate frosting. Perfect for celebrations!',
        'dishTypes': ['dessert'],
        'vegetarian': true,
        'vegan': false,
        'glutenFree': false,
        'dairyFree': false,
        'healthScore': 25.0,
        'ingredients': [
          {'name': 'All-Purpose Flour', 'amount': '2', 'unit': 'cups'},
          {'name': 'Cocoa Powder', 'amount': '3/4', 'unit': 'cup'},
          {'name': 'Sugar', 'amount': '2', 'unit': 'cups'},
          {'name': 'Eggs', 'amount': '3', 'unit': 'whole'},
          {'name': 'Milk', 'amount': '1', 'unit': 'cup'},
          {'name': 'Butter', 'amount': '150', 'unit': 'g'},
          {'name': 'Vanilla Extract', 'amount': '2', 'unit': 'tsp'},
        ],
        'nutrition': {
          'calories': '620 kcal',
          'protein': '8g',
          'carbs': '85g',
          'fat': '28g',
        },
      },
      {
        'id': 6,
        'title': 'Grilled Salmon',
        'image': 'https://images.unsplash.com/photo-1485921325833-c519f76c4927?w=400',
        'readyInMinutes': 20,
        'servings': 2,
        'summary': 'Fresh salmon fillets grilled to perfection with lemon and herbs. Healthy and delicious!',
        'dishTypes': ['lunch', 'main course', 'dinner'],
        'vegetarian': false,
        'vegan': false,
        'glutenFree': true,
        'dairyFree': true,
        'healthScore': 85.0,
        'ingredients': [
          {'name': 'Salmon Fillets', 'amount': '2', 'unit': 'pieces'},
          {'name': 'Lemon', 'amount': '1', 'unit': 'whole'},
          {'name': 'Olive Oil', 'amount': '2', 'unit': 'tbsp'},
          {'name': 'Fresh Dill', 'amount': '2', 'unit': 'tbsp'},
          {'name': 'Garlic', 'amount': '2', 'unit': 'cloves'},
          {'name': 'Salt', 'amount': '1', 'unit': 'tsp'},
          {'name': 'Black Pepper', 'amount': '1/2', 'unit': 'tsp'},
        ],
        'nutrition': {
          'calories': '380 kcal',
          'protein': '42g',
          'carbs': '3g',
          'fat': '22g',
        },
      },
      {
        'id': 7,
        'title': 'Beef Tacos',
        'image': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400',
        'readyInMinutes': 30,
        'servings': 4,
        'summary': 'Spicy ground beef tacos with fresh toppings and crunchy shells. A Mexican favorite!',
        'dishTypes': ['lunch', 'main course', 'dinner'],
        'vegetarian': false,
        'vegan': false,
        'glutenFree': false,
        'dairyFree': false,
        'healthScore': 52.0,
        'ingredients': [
          {'name': 'Ground Beef', 'amount': '500', 'unit': 'g'},
          {'name': 'Taco Shells', 'amount': '8', 'unit': 'pieces'},
          {'name': 'Lettuce', 'amount': '1', 'unit': 'head'},
          {'name': 'Tomatoes', 'amount': '2', 'unit': 'whole'},
          {'name': 'Cheddar Cheese', 'amount': '150', 'unit': 'g'},
          {'name': 'Sour Cream', 'amount': '100', 'unit': 'ml'},
          {'name': 'Taco Seasoning', 'amount': '2', 'unit': 'tbsp'},
        ],
        'nutrition': {
          'calories': '495 kcal',
          'protein': '32g',
          'carbs': '38g',
          'fat': '24g',
        },
      },
      {
        'id': 8,
        'title': 'Greek Salad',
        'image': 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400',
        'readyInMinutes': 10,
        'servings': 4,
        'summary': 'Fresh Mediterranean salad with cucumbers, tomatoes, olives, and feta cheese.',
        'dishTypes': ['salad', 'side dish', 'lunch'],
        'vegetarian': true,
        'vegan': false,
        'glutenFree': true,
        'dairyFree': false,
        'healthScore': 78.0,
        'ingredients': [
          {'name': 'Cucumbers', 'amount': '2', 'unit': 'whole'},
          {'name': 'Tomatoes', 'amount': '3', 'unit': 'whole'},
          {'name': 'Red Onion', 'amount': '1', 'unit': 'whole'},
          {'name': 'Kalamata Olives', 'amount': '1', 'unit': 'cup'},
          {'name': 'Feta Cheese', 'amount': '200', 'unit': 'g'},
          {'name': 'Olive Oil', 'amount': '3', 'unit': 'tbsp'},
          {'name': 'Lemon Juice', 'amount': '2', 'unit': 'tbsp'},
        ],
        'nutrition': {
          'calories': '285 kcal',
          'protein': '10g',
          'carbs': '15g',
          'fat': '22g',
        },
      },
      {
        'id': 9,
        'title': 'Pad Thai',
        'image': 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400',
        'readyInMinutes': 35,
        'servings': 3,
        'summary': 'Classic Thai stir-fried noodles with shrimp, peanuts, and tangy tamarind sauce.',
        'dishTypes': ['lunch', 'main course', 'dinner'],
        'vegetarian': false,
        'vegan': false,
        'glutenFree': true,
        'dairyFree': true,
        'healthScore': 62.0,
        'ingredients': [
          {'name': 'Rice Noodles', 'amount': '300', 'unit': 'g'},
          {'name': 'Shrimp', 'amount': '250', 'unit': 'g'},
          {'name': 'Eggs', 'amount': '2', 'unit': 'whole'},
          {'name': 'Bean Sprouts', 'amount': '1', 'unit': 'cup'},
          {'name': 'Peanuts', 'amount': '1/2', 'unit': 'cup'},
          {'name': 'Tamarind Paste', 'amount': '2', 'unit': 'tbsp'},
          {'name': 'Fish Sauce', 'amount': '2', 'unit': 'tbsp'},
          {'name': 'Green Onions', 'amount': '3', 'unit': 'stalks'},
        ],
        'nutrition': {
          'calories': '445 kcal',
          'protein': '26g',
          'carbs': '52g',
          'fat': '16g',
        },
      },
      {
        'id': 10,
        'title': 'French Onion Soup',
        'image': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400',
        'readyInMinutes': 50,
        'servings': 4,
        'summary': 'A comforting French classic with caramelized onions in rich beef broth, topped with melted cheese.',
        'dishTypes': ['soup', 'starter'],
        'vegetarian': false,
        'vegan': false,
        'glutenFree': false,
        'dairyFree': false,
        'healthScore': 48.0,
        'ingredients': [
          {'name': 'Onions', 'amount': '6', 'unit': 'large'},
          {'name': 'Beef Broth', 'amount': '6', 'unit': 'cups'},
          {'name': 'Butter', 'amount': '50', 'unit': 'g'},
          {'name': 'Gruyere Cheese', 'amount': '200', 'unit': 'g'},
          {'name': 'Baguette', 'amount': '1', 'unit': 'whole'},
          {'name': 'White Wine', 'amount': '1/2', 'unit': 'cup'},
          {'name': 'Thyme', 'amount': '2', 'unit': 'tsp'},
        ],
        'nutrition': {
          'calories': '390 kcal',
          'protein': '18g',
          'carbs': '42g',
          'fat': '16g',
        },
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getRandomRecipes({int number = 10}) async {
    try {
      final url = Uri.parse('$_baseUrl/recipes/random?apiKey=$_apiKey&number=$number');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['recipes']);
      } else if (response.statusCode == 402) {
        print('API quota exceeded, using mock data');
        return _getMockRecipes();
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching random recipes: $e, using mock data');
      return _getMockRecipes();
    }
  }
  Future<List<Map<String, dynamic>>> searchRecipes(String query, {int number = 10}) async {
    try {
      final url = Uri.parse('$_baseUrl/recipes/complexSearch?apiKey=$_apiKey&query=$query&number=$number&addRecipeInformation=true');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else if (response.statusCode == 402) {
        print('API quota exceeded, using mock data');
        return _getMockRecipes().where((recipe) => 
          recipe['title'].toString().toLowerCase().contains(query.toLowerCase())
        ).toList();
      } else {
        throw Exception('Failed to search recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching recipes: $e, using mock data');
      return _getMockRecipes().where((recipe) => 
        recipe['title'].toString().toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }
  Future<Map<String, dynamic>?> getRecipeById(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/recipes/$id/information?apiKey=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load recipe details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipe by ID: $e');
      return null;
    }
  }
  Future<List<Map<String, dynamic>>> getRecipesByCategory(String cuisine, {int number = 10}) async {
    try {
      final url = Uri.parse('$_baseUrl/recipes/complexSearch?apiKey=$_apiKey&cuisine=$cuisine&number=$number&addRecipeInformation=true');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else if (response.statusCode == 402) {
        print('API quota exceeded, using mock data');
        return _getMockRecipes();
      } else {
        throw Exception('Failed to load recipes by category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipes by category: $e, using mock data');
      return _getMockRecipes();
    }
  }
  Future<List<Map<String, dynamic>>> getPopularRecipes({int number = 10}) async {
    try {
      final url = Uri.parse('$_baseUrl/recipes/complexSearch?apiKey=$_apiKey&sort=popularity&number=$number&addRecipeInformation=true');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else if (response.statusCode == 402) {
        print('API quota exceeded, using mock data');
        return _getMockRecipes();
      } else {
        throw Exception('Failed to load popular recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching popular recipes: $e, using mock data');
      return _getMockRecipes();
    }
  }
  Future<Map<String, dynamic>?> getRecipeNutrition(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/recipes/$id/nutritionWidget.json?apiKey=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load nutrition info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching nutrition: $e');
      return null;
    }
  }
  Future<List<Map<String, dynamic>>> getSimilarRecipes(int id, {int number = 5}) async {
    try {
      final url = Uri.parse('$_baseUrl/recipes/$id/similar?apiKey=$_apiKey&number=$number');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load similar recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching similar recipes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchRecipesByIngredients(String ingredients, {int number = 10}) async {
    try {
      final url = Uri.parse('$_baseUrl/recipes/findByIngredients?apiKey=$_apiKey&ingredients=$ingredients&number=$number&ranking=2');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        // Convert to our format
        return results.map((recipe) => {
          'id': recipe['id'],
          'title': recipe['title'],
          'image': recipe['image'],
          'readyInMinutes': 30, // Default value
          'servings': 4, // Default value
        }).toList();
      } else if (response.statusCode == 402) {
        print('API quota exceeded, using mock data');
        return _getMockRecipes();
      } else {
        throw Exception('Failed to search recipes by ingredients: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching recipes by ingredients: $e, using mock data');
      return _getMockRecipes();
    }
  }
}
