import 'package:bazar/features/home/domain/entites/market_category.dart';

abstract class MarketRepository {
  Future<List<MarketCategory>> getCategories();
}