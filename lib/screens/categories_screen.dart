import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/category.dart';
import 'category_meals_screen.dart';
import 'meal_detail_screen.dart'; // needed for navigation to detail

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<MealCategory> categories = [];
  List<MealCategory> filtered = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    try {
      categories = await ApiService.fetchCategories();
      filtered = categories;
      setState(() => loading = false);
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load categories')),
      );
    }
  }

  void search(String query) {
    final q = query.toLowerCase().trim();
    final results = categories
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();

    setState(() {
      filtered = results;
    });
  }

  Future<void> _openRandomMeal() async {
    // show a short loading SnackBar
    final sb = SnackBar(
      content: Row(
        children: const [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 12),
          Text('Fetching random meal...'),
        ],
      ),
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(sb);

    try {
      final meal = await ApiService.fetchRandomMeal();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (meal == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No random meal found')));
        return;
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: meal.id)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      debugPrint('Random meal error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to fetch random meal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        actions: [
          IconButton(
            tooltip: 'Random meal',
            icon: const Icon(Icons.shuffle),
            onPressed: _openRandomMeal,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: search,
              decoration: const InputDecoration(
                hintText: "Search categories...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final cat = filtered[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      cat.thumbnail,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                    title: Text(cat.name),
                    subtitle: Text(
                      cat.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategoryMealsScreen(category: cat.name)),
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
