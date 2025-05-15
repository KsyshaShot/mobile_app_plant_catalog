import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Map<String, TextEditingController> controllers = {
    'first_name': TextEditingController(),
    'last_name': TextEditingController(),
    'city': TextEditingController(),
    'about': TextEditingController(),
  };

  bool isLoading = true;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      controllers.forEach((key, controller) {
        controller.text = data[key] ?? '';
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    final updatedData = {
      for (var entry in controllers.entries) entry.key: entry.value.text,
    };

    await firestore.collection('users').doc(uid).update(updatedData);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'birthday': Timestamp.fromDate(_selectedBirthDate!)});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Профиль обновлен')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Редактирование профиля')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<String> fieldNames = ["Имя", "Фамилия", /*"Дата рождения",*/ "Город", "О себе"];
    int index = 0;

    return Scaffold(
      appBar: AppBar(title: Text('Редактирование профиля')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            for (var entry in controllers.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: fieldNames.elementAt(index++),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            SizedBox(height: 8),
            InkWell(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedBirthDate ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  setState(() {
                    _selectedBirthDate = pickedDate;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Дата рождения',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  (_selectedBirthDate != null ? _selectedBirthDate.toString() : 'Выберите дату'),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Сохранить изменения'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
