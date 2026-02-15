import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/state/login_notifier.dart';

void main() {
  final remote = AuthRemoteDataSource();
  final repository = AuthRepositoryImpl(remote);
  final loginUseCase = LoginUseCase(repository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginNotifier(loginUseCase),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}


