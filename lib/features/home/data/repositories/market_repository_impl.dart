import 'package:bazar/features/home/domain/entites/market_category.dart';
import 'package:bazar/features/home/domain/entites/repositories/market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  @override
  Future<List<MarketCategory>> getCategories() async {
    return [
      MarketCategory(title: "Продукты", route: "/products", imagePath: "assets/images/prod.png"),
      MarketCategory(title: "Мир рыбака", route: "/fishing", imagePath: "assets/images/ryba.png"),
      MarketCategory(title: "Одежда", route: "/clothing", imagePath: "assets/images/koft.png"),
      MarketCategory(title: "Зайза", route: "/zayza", imagePath: "assets/images/valut.png"),
      MarketCategory(title: "kaspi kz", route: "/kaspi", imagePath: "assets/images/kaspi.png"),
      MarketCategory(title: "smart", route: "/smart", imagePath: "assets/images/smart.png"),
    ];
  }
}
