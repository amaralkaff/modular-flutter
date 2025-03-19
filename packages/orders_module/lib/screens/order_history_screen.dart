import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:orders_module/bloc/order_bloc.dart';
import 'package:orders_module/bloc/order_event.dart';
import 'package:orders_module/bloc/order_state.dart';
import 'package:orders_module/models/order_model.dart' as order_model;
import 'package:orders_module/screens/order_tracking_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String userId;
  final bool isCustomer;

  const OrderHistoryScreen({
    super.key,
    required this.userId,
    this.isCustomer = true,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  void _loadOrders() {
    if (widget.isCustomer) {
      context.read<OrderBloc>().add(LoadCustomerOrders(widget.userId));
    } else {
      context.read<OrderBloc>().add(LoadRestaurantOrders(widget.userId));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Orders'),
            Tab(text: 'Past Orders'),
          ],
        ),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrdersLoaded) {
            final activeOrders = state.orders.where((order) => 
              order.status != order_model.OrderStatus.delivered && 
              order.status != order_model.OrderStatus.cancelled
            ).toList();
            
            final pastOrders = state.orders.where((order) => 
              order.status == order_model.OrderStatus.delivered || 
              order.status == order_model.OrderStatus.cancelled
            ).toList();
            
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(activeOrders),
                _buildOrdersList(pastOrders),
              ],
            );
          } else if (state is OrderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadOrders,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: widget.isCustomer
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to place new order screen
                // This would be implemented when we add the place order screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Place New Order functionality coming soon!'),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildOrdersList(List<order_model.Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            if (_tabController.index == 0 && widget.isCustomer) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to place new order screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Place New Order functionality coming soon!'),
                    ),
                  );
                },
                child: const Text('Place New Order'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(context, order);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, order_model.Order order) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/order-tracking',
            arguments: order.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(order.status),
                      color: _getStatusColor(order.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id.substring(0, 8)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    _getStatusColor(order.status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order.status.name,
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order.restaurantName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (order.status != order_model.OrderStatus.delivered &&
                  order.status != order_model.OrderStatus.cancelled)
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/order-tracking',
                      arguments: order.id,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('Track Order'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(order_model.OrderStatus status) {
    switch (status) {
      case order_model.OrderStatus.pending:
        return Colors.orange;
      case order_model.OrderStatus.preparing:
        return Colors.blue;
      case order_model.OrderStatus.readyForPickup:
        return Colors.amber;
      case order_model.OrderStatus.pickedUp:
        return Colors.indigo;
      case order_model.OrderStatus.inDelivery:
        return Colors.purple;
      case order_model.OrderStatus.delivered:
        return Colors.green;
      case order_model.OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(order_model.OrderStatus status) {
    switch (status) {
      case order_model.OrderStatus.pending:
        return Icons.schedule;
      case order_model.OrderStatus.preparing:
        return Icons.restaurant;
      case order_model.OrderStatus.readyForPickup:
        return Icons.takeout_dining;
      case order_model.OrderStatus.pickedUp:
        return Icons.delivery_dining;
      case order_model.OrderStatus.inDelivery:
        return Icons.directions_car;
      case order_model.OrderStatus.delivered:
        return Icons.check_circle;
      case order_model.OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
} 