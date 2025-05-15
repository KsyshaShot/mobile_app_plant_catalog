import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//состояние экрана для переключения между регистр. и авториз.
class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLogin = true; //по умолчанию - вход
  String? errorMessage;

  Future<void> _authenticate() async {
    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        //создаем нового юзера
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        String uid = userCredential.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'first_name': '',
          'last_name': '',
          'birthday': Timestamp.fromDate(DateTime.now()),
          'city': '',
          'about': '',
          'avatar_url': '',
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _getErrorMessage(e.code);
        print('------------------------ОШИБКА--${e.code}----------------------------');
      });
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'channel-error':
        return 'Заполните поля для аутентификации.';
      case 'invalid-credential':
        return 'Неправильный логин или пароль';
      case 'invalid-email':
        return 'Неправильный формат email.';
      case 'user-disabled':
        return 'Этот аккаунт отключён.';
      case 'user-not-found':
        return 'Пользователь с таким email не найден.';
      case 'wrong-password':
        return 'Неверный пароль.';
      case 'email-already-in-use':
        return 'Email уже используется.';
      case 'operation-not-allowed':
        return 'Операция запрещена.';
      case 'weak-password':
        return 'Пароль слишком слабый. Используйте минимум 6 символов.';
      default:
        return 'Произошла неизвестная ошибка. Попробуйте снова.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Вход' : 'Регистрация',
          style: TextStyle(color: Color(0xFF51201E)))),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              cursorColor: Color(0xFF3E875C),
              style: TextStyle(color: Color(0xFF371817)),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true, //скрывает в точечки
              cursorColor: Color(0xFF3E875C),
              style: TextStyle(color: Color(0xFF371817)),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Color(0xFF51201E)),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: Text(isLogin ? 'Войти' : 'Зарегистрироваться'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                  errorMessage = null;
                });
              },
              child: Text(isLogin ? 'Создать аккаунт' : 'Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }
}


