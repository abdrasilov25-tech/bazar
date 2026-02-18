import 'package:bazar/features/home/domain/entites/market_category.dart';
import 'package:bazar/features/home/domain/entites/repositories/market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  @override
  Future<List<MarketCategory>> getCategories() async {
    return [
      MarketCategory(title: "Продукты", route: "/products"),
      MarketCategory(title: "Мир рыбака", route: "/fishing"),
      MarketCategory(title: "Одежда", route: "/clothing"),
      MarketCategory(title: "Зайза(пункт обмена валют)", route: "/zayza"),
      MarketCategory(title: "kaspi kz(банкомат)", route: "/kaspi"),
      MarketCategory(title: "smart(сервисный центр)", route: "/smart"),
    ];
  }
}
