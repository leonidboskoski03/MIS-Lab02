import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/meal_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;
  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  MealDetail? meal;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final m = await ApiService.lookupMealById(widget.mealId);
      meal = m;
    } catch (e) {
      debugPrint('Lookup error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _openYoutube() async {
    if (meal == null || meal!.youtube.isEmpty) return;
    final url = meal!.youtube;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open YouTube')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal?.name ?? 'Meal'),
        actions: meal != null && meal!.youtube.isNotEmpty
            ? [
          IconButton(
            icon: const Icon(Icons.play_circle_fill),
            onPressed: _openYoutube,
          )
        ]
            : null,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : meal == null
          ? const Center(child: Text('Meal not found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: meal!.thumbnail,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              placeholder: (c, s) => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
              errorWidget: (c, s, e) => const SizedBox(height: 220, child: Center(child: Icon(Icons.error))),
            ),
            const SizedBox(height: 12),
            Text(meal!.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Category: ${meal!.category} — Area: ${meal!.area}'),
            const SizedBox(height: 12),
            const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...meal!.ingredients.map((ing) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text('${ing['ingredient']} — ${ing['measure']}'),
              );
            }).toList(),
            const SizedBox(height: 12),
            const Text('Instructions', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(meal!.instructions),
            const SizedBox(height: 20),
            if (meal!.youtube.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _openYoutube,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Watch on YouTube'),
              ),
          ],
        ),
      ),
    );
  }
}
