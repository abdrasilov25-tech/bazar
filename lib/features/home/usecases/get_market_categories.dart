
import 'package:bazar/features/home/domain/entites/market_category.dart';
import 'package:bazar/features/home/domain/entites/repositories/market_repository.dart';

class GetMarketCategories {
  final MarketRepository repository;

  GetMarketCategories(this.repository);

  Future<List<MarketCategory>> call() {
    return repository.getCategories();
  }
}