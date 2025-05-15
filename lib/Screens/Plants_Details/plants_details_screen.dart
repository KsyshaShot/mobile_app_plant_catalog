import 'package:flutter/material.dart';
import 'package:lab_1/models/PlantsDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlantDetailsScreen extends StatefulWidget {
  final PlantDetails plant;

  const PlantDetailsScreen({super.key, required this.plant});

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(widget.plant.name)
        .get();

    setState(() {
      isFavorite = doc.exists;
    });
  }

  Future<void> _toggleFavorite() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(widget.plant.name);

    if (isFavorite) {
      await favRef.delete();
    } else {
      await favRef.set({
        'plant_name': widget.plant.name,
      });
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Color(0xFF15914C) : Color(0xFF15914C),
            ),
            onPressed: _toggleFavorite,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 350 ,
              child: PageView.builder(
                itemCount: widget.plant.imageUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.plant.imageUrls[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Описание: ${widget.plant.description}'),
            const SizedBox(height: 8),
            Text('Полив: ${widget.plant.watering}'),
            const SizedBox(height: 8),
            Text('Освещение: ${widget.plant.lighting}'),
            const SizedBox(height: 8),
            Text('Температура: ${widget.plant.temperature}'),
          ],
        ),
      ),
    );
  }
}

