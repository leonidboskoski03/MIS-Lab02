import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection('favorites');

  Future<void> addFavorite(String mealId, String mealName) async {
    await _collection.add({
      'mealId': mealId,
      'mealName': mealName,
    });
  }

  Future<void> removeFavorite(String mealId) async {
    final snapshot = await _collection.where('mealId', isEqualTo: mealId).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<bool> isFavorite(String mealId) async {
    final snapshot = await _collection.where('mealId', isEqualTo: mealId).get();
    return snapshot.docs.isNotEmpty;
  }

  Stream<List<Map<String, dynamic>>> getFavorites() {
    return _collection.snapshots().map((snapshot) => snapshot.docs.map((doc) => {
      'id': doc.id,
      'mealId': doc['mealId'],
      'mealName': doc['mealName'],
    }).toList());
  }
}
