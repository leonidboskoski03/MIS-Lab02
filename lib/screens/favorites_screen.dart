import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../widgets/meal_grid_item.dart';
import '../models/meal_summary.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final FavoritesService favoriteService;

  const FavoritesScreen({super.key, required this.favoriteService});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: widget.favoriteService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const Center(
              child: Text("No favorite meals yet"),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final fav = favorites[index];
              return MealGridItem(
                meal: MealSummary(
                  id: fav['mealId'],
                  name: fav['mealName'],
                  thumbnail: fav['thumbnail'] ?? '',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealDetailScreen(mealId: fav['mealId']),
                    ),
                  );
                },
                favoriteService: widget.favoriteService,
              );
            },
          );
        },
      ),
    );
  }
}
