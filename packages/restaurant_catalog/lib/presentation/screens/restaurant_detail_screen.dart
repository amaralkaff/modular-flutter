import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import '../../models/menu_item.dart';
import '../../repositories/restaurant_repository.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;
  final RestaurantRepository repository;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
    required this.repository,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
    if (widget.restaurant.menuCategories.isNotEmpty) {
      _selectedCategory = widget.restaurant.menuCategories.first;
    }
  }

  Future<void> _loadMenuItems() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final menuItems = await widget.repository.getRestaurantMenu(widget.restaurant.id);
      
      setState(() {
        _menuItems = menuItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<MenuItem> get _filteredMenuItems {
    if (_selectedCategory.isEmpty) return _menuItems;
    return _menuItems.where((item) => item.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildRestaurantInfo(),
          _buildCategoryTabs(),
          _buildMenuItems(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          widget.restaurant.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // Implement favorite functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Implement share functionality
          },
        ),
      ],
    );
  }

  Widget _buildRestaurantInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.restaurant.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.restaurant.isOpen
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.restaurant.isOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                      color: widget.restaurant.isOpen
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber[700],
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.restaurant.rating.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' (${widget.restaurant.totalRatings})',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.restaurant.cuisine,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.restaurant.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  Icons.delivery_dining,
                  '${widget.restaurant.estimatedDeliveryTime} min',
                ),
                _buildInfoItem(
                  Icons.attach_money,
                  '\$${widget.restaurant.deliveryFee.toStringAsFixed(2)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: widget.restaurant.menuCategories.length,
          itemBuilder: (context, index) {
            final category = widget.restaurant.menuCategories[index];
            final isSelected = category == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              ElevatedButton(
                onPressed: _loadMenuItems,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final menuItem = _filteredMenuItems[index];
            return _MenuItemCard(menuItem: menuItem);
          },
          childCount: _filteredMenuItems.length,
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;

  const _MenuItemCard({
    super.key,
    required this.menuItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            child: Image.network(
              menuItem.imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menuItem.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${menuItem.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (menuItem.customizationOptions.isNotEmpty)
                        Text(
                          'Customizable',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                    ],
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