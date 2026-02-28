import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// Bloc и UseCase
import 'features/home/usecases/get_market_categories.dart';
import 'features/home/data/repositories/market_repository_impl.dart';
import 'features/home/presentation/cubit/market_cubit.dart';
import 'core/routes/app_router.dart';
import 'core/state/app_session.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Восстановление .env из резервной копии, если основного файла нет
  if (!File('.env').existsSync() && File('.env.backup').existsSync()) {
    File('.env.backup').copySync('.env');
    debugPrint(".env не найден. Восстановлено из .env.backup");
  }

  // 🔹 Загружаем .env (относительный путь, ищет .env в корне проекта)
  try {
    await dotenv.load();
    debugPrint(".env успешно загружен");
  } catch (e) {
    debugPrint("Не удалось загрузить .env: $e");
  }

  // 🔹 Логирование всех ключей в debug-режиме
  if (kDebugMode) {
    debugPrint("Все ключи .env:");
    dotenv.env.forEach((key, value) {
      debugPrint("$key = $value");
    });
  }

  // 🔹 Получаем ключи Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  // 🔹 Если ключи пустые — показываем экран ошибки
  if (supabaseUrl == null || supabaseKey == null) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Ошибка: .env не найден или ключи пустые',
              style: const TextStyle(color: Colors.red, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    return;
  }

  // 🔹 Функция для безопасного запуска приложения
  void runSafeApp(Widget app) {
    try {
      runApp(app);
    } catch (e, stack) {
      debugPrint("Ошибка при запуске приложения: $e");
      debugPrintStack(stackTrace: stack);
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                'Произошла ошибка при запуске приложения',
                style: const TextStyle(color: Colors.red, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }
  }

  // 🔹 Основная инициализация Supabase и Bloc
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );

    final repository = MarketRepositoryImpl();
    final useCase = GetMarketCategories(repository);

    final appSession = AppSession();
    await appSession.ready;

    runSafeApp(MyApp(useCase: useCase, session: appSession));
  } catch (e, stack) {
    debugPrint("Ошибка инициализации Supabase или Bloc: $e");
    debugPrintStack(stackTrace: stack);
    runSafeApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Произошла ошибка при инициализации приложения',
              style: const TextStyle(color: Colors.red, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final GetMarketCategories useCase;
  final AppSession session;

  const MyApp({super.key, required this.useCase, required this.session});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: session,
      child: BlocProvider(
        create: (_) => MarketCubit(useCase),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: '/',
        ),
      ),
    );
  }
}