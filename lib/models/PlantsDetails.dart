import 'package:lab_1/models/Plant.dart';

class PlantDetails extends Plant {
  final String description;
  final String watering;
  final String lighting;
  final String temperature;
  final List<String> imageUrls;

  PlantDetails({
    required String name,
    required this.imageUrls,
    required this.description,
    required this.watering,
    required this.lighting,
    required this.temperature,
  }) : super(name: name, imageUrl: imageUrls.first);

  factory PlantDetails.fromMap(Map<String, dynamic> data) {
    return PlantDetails(
      name: data['name'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      description: data['description'] ?? '',
      watering: data['watering'] ?? '',
      lighting: data['lighting'] ?? '',
      temperature: data['temperature'] ?? '',
    );
  }
}

