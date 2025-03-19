import '../../models/menu_item.dart';
import '../../repositories/restaurant_repository.dart';

class SearchMenuItemsUseCase {
  final RestaurantRepository _repository;

  SearchMenuItemsUseCase(this._repository);

  Future<List<MenuItem>> execute(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final menuItems = await _repository.searchMenuItems(query);
      
      // Sort by price
      menuItems.sort((a, b) => a.price.compareTo(b.price));
      
      return menuItems;
    } catch (e) {
      throw Exception('Failed to search menu items: $e');
    }
  }
} 