import 'package:bazar/features/home/usecases/get_market_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bazar/features/home/data/repositories/market_repository_impl.dart';
import 'package:bazar/features/home/presentation/cubit/market_cubit.dart';
import 'package:bazar/core/routes/app_router.dart';
void main() {
  final repository = MarketRepositoryImpl();      // Data
  final useCase = GetMarketCategories(repository); // Domain

  runApp(MyApp(useCase: useCase));                // Presentation
}

class MyApp extends StatelessWidget {
  final GetMarketCategories useCase;

  const MyApp({super.key, required this.useCase});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MarketCubit(useCase),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}


