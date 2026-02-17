import 'package:bazar/features/home/domain/entites/market_category.dart';
import 'package:bazar/features/home/usecases/get_market_categories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MarketCubit extends Cubit<List<MarketCategory>> {
  final GetMarketCategories getCategories;

  MarketCubit(this.getCategories) : super([]);

  void loadCategories() async {
    final categories = await getCategories();
    emit(categories);
  }
}