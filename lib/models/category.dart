class MealCategory {
  final String id;
  final String name;
  final String description;
  final String thumbnail;

  MealCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnail,
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      id: json['idCategory'],
      name: json['strCategory'],
      description: json['strCategoryDescription'],
      thumbnail: json['strCategoryThumb'],
    );
  }
}
