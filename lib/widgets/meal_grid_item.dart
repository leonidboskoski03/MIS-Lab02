import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/meal_summary.dart';
import '../services/favorites_service.dart';

class MealGridItem extends StatefulWidget {
  final MealSummary meal;
  final VoidCallback onTap;
  final FavoritesService favoriteService;

  const MealGridItem({
    super.key,
    required this.meal,
    required this.onTap,
    required this.favoriteService,
  });

  @override
  State<MealGridItem> createState() => _MealGridItemState();
}

class _MealGridItemState extends State<MealGridItem> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final fav = await widget.favoriteService.isFavorite(widget.meal.id);
    setState(() => isFavorite = fav);
  }

  void _toggleFavorite() async {
    if (isFavorite) {
      await widget.favoriteService.removeFavorite(widget.meal.id);
    } else {
      await widget.favoriteService.addFavorite(widget.meal.id, widget.meal.name);
    }
    setState(() => isFavorite = !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: widget.meal.thumbnail,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (c, s) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (c, s, e) => const Icon(Icons.error),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.meal.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _toggleFavorite,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
