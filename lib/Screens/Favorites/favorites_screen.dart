import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab_1/models/PlantsDetails.dart';
import 'package:lab_1/Screens/Plants_Details/plants_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<List<PlantDetails>> _loadFavoritePlants() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final favoritesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();

    final favoriteNames = favoritesSnapshot.docs.map((doc) => doc.id).toList();

    final plantsSnapshot = await FirebaseFirestore.instance
        .collection('plants')
        .get();

    final allPlants = plantsSnapshot.docs.map((doc) {
      final data = doc.data();
      return PlantDetails(
        name: data['name'] ?? '',
        imageUrls: List<String>.from(data['imageUrls'] ?? []),
        description: data['description'] ?? '',
        watering: data['watering'] ?? '',
        lighting: data['lighting'] ?? '',
        temperature: data['temperature'] ?? '',
      );
    }).toList();

    return allPlants
        .where((plant) => favoriteNames.contains(plant.name))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранные растения'),
      ),
      body: FutureBuilder<List<PlantDetails>>(
        future: _loadFavoritePlants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет избранных растений.'));
          }

          final plants = snapshot.data!;

          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];

              return ListTile(
                leading: Image.network(plant.imageUrl, width: 60, height: 60, fit: BoxFit.cover,),
                title: Text(plant.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlantDetailsScreen(plant: plant),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
