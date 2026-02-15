import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/login_notifier.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginNotifier = Provider.of<LoginNotifier>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Фоновая картинка
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.png', // путь к твоей картинке
              fit: BoxFit.cover,             // растянуть на весь экран
            ),
          ),

          // Контент поверх картинки
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Заголовок
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8), // делаем поле читаемым
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),

                  // Кнопка Login
                  ElevatedButton(
                    onPressed: () {
                      loginNotifier.login('test@email.com', 'password');
                    },
                    child: loginNotifier.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  