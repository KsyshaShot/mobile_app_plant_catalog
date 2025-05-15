import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lab_1/models/UserProfile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    print('UID----ПРОФИЛЯ---' + uid + '--------------------------------------------------');
    if (doc.exists) {
      print('ПРОФИЛЬ---ЗАГРУЖАЕТСЯ----------------------------------------------------------');
      setState(() {
        userProfile = UserProfile.fromMap(doc.data()!);
        print('ЗАГРУЖЕН ПРОФИЛЬ ПОЛЬЗОВАТЕЛЯ');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (userProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        ),
        body: Center(child: Text('Профиль не найден')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /*CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userProfile!.avatarUrl),
            ),*/
            const SizedBox(height: 20),
            _buildField('Имя', userProfile!.firstName),
            _buildField('Фамилия', userProfile!.lastName),
            _buildField('Дата рождения', userProfile!.toDate()),
            _buildField('Город', userProfile!.city),
            _buildField('О себе', userProfile!.about),
            _buildField('email', user!.email ?? 'Не найдено'),
            _buildField('UID', user.uid),
            _buildField('Дата создания', user.metadata.creationTime.toString()),
            _buildField('Последний вход', user.metadata.lastSignInTime.toString()),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/edit_profile');
              },
              label: Text('Редактировать профиль'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3E875C),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(
                    fontSize: 16,
                    fontFamily: 'ShantellSans'),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final emailController = TextEditingController();
                final passwordController = TextEditingController();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Повторная авторизация'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Пароль'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Удалить'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  final cred = EmailAuthProvider.credential(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                  await user!.reauthenticateWithCredential(cred);
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                  await user.delete();
                  Navigator.of(context).pushReplacementNamed('/');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка удаления: $e')),
                  );
                }
              },
              label: const Text('Удалить аккаунт'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7C302A)),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
