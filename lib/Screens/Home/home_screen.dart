import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lab_1/models/PlantsDetails.dart';
import 'package:lab_1/Screens/Plants_Details/plants_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plantsStream = FirebaseFirestore.instance.collection('plants').snapshots();
    return Scaffold(
      appBar: AppBar(
          title: const Text('Домашние растения'),
          actions: [
            PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'favorites') {
                Navigator.pushNamed(context, '/favorites');
              } else if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'favorites',
                child: Text('Избранное'),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Text('Профиль'),
              ),
            ],
            ),
          ],
      ),
      body: StreamBuilder<QuerySnapshot>( //QuerySnapshot - в нем наши доки, и их внутренняя инфа (и ошибки)
        stream: plantsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки данных'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final plant = PlantDetails.fromMap(data);

              return ListTile(
                leading: Image.network(plant.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
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

