import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

class ApiService {
  static const String _base = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<MealCategory>> fetchCategories() async {
    final res = await http.get(Uri.parse('$_base/categories.php'));
    if (res.statusCode != 200) throw Exception('Failed to load categories');
    final Map<String, dynamic> json = jsonDecode(res.body);
    final List data = json['categories'] ?? [];
    return data.map((e) => MealCategory.fromJson(e)).toList();
  }

  static Future<List<MealSummary>> fetchMealsByCategory(String category) async {
    final res = await http.get(Uri.parse('$_base/filter.php?c=${Uri.encodeComponent(category)}'));
    if (res.statusCode != 200) throw Exception('Failed to load meals');
    final Map<String, dynamic> json = jsonDecode(res.body);
    final List data = json['meals'] ?? [];
    return data.map((e) => MealSummary.fromJson(e)).toList();
  }

  static Future<List<MealSummary>> searchMeals(String query) async {
    final res = await http.get(Uri.parse('$_base/search.php?s=${Uri.encodeComponent(query)}'));
    if (res.statusCode != 200) throw Exception('Search failed');
    final Map<String, dynamic> json = jsonDecode(res.body);
    final List? data = json['meals'];
    if (data == null) return [];
    return data.map((e) => MealSummary.fromJson(e)).toList();
  }

  static Future<MealDetail?> lookupMealById(String id) async {
    final res = await http.get(Uri.parse('$_base/lookup.php?i=${Uri.encodeComponent(id)}'));
    if (res.statusCode != 200) throw Exception('Lookup failed');
    final Map<String, dynamic> json = jsonDecode(res.body);
    final List? data = json['meals'];
    if (data == null || data.isEmpty) return null;
    return MealDetail.fromJson(data[0]);
  }

  static Future<MealDetail?> fetchRandomMeal() async {
    final res = await http.get(Uri.parse('$_base/random.php'));
    if (res.statusCode != 200) throw Exception('Random failed');
    final Map<String, dynamic> json = jsonDecode(res.body);
    final List? data = json['meals'];
    if (data == null || data.isEmpty) return null;
    return MealDetail.fromJson(data[0]);
  }
}
