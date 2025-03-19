import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orders_module/bloc/order_bloc.dart';
import 'package:orders_module/bloc/order_state.dart';
import 'package:orders_module/models/order_model.dart' as order_model;
import 'package:intl/intl.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderCreated) {
            return _buildSuccessContent(context, state.orderId);
          } else if (state is OrderDetailsLoaded) {
            return _buildOrderDetails(context, state.order);
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
    );
  }

  Widget _buildSuccessContent(BuildContext context, String orderId) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            'Order Placed Successfully!',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your order #${orderId.substring(0, 8)} has been received and is being processed.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            'You will receive updates about your order in the Orders section.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Track My Order'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, order_model.Order order) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          order.status.name,
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Restaurant: ${order.restaurantName}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ordered on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (order.estimatedDeliveryTime != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Estimated delivery: ${DateFormat('hh:mm a').format(order.estimatedDeliveryTime!)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Order Items',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('${item.quantity}x ${currencyFormat.format(item.price)}'),
                  trailing: Text(
                    currencyFormat.format(item.totalPrice),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal', currencyFormat.format(order.subtotal)),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Delivery Fee', currencyFormat.format(order.deliveryFee)),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Tax', currencyFormat.format(order.tax)),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Total',
                    currencyFormat.format(order.total),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Delivery Address',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(order.deliveryAddress),
            ),
          ),
          const SizedBox(height: 32),
          if (order.status == order_model.OrderStatus.pending || 
              order.status == order_model.OrderStatus.preparing)
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Show cancel order dialog
                  _showCancelOrderDialog(context, order.id);
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
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

  void _showCancelOrderDialog(BuildContext context, String orderId) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to cancel this order? This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep Order'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim().isNotEmpty
                  ? reasonController.text.trim()
                  : 'Customer requested cancellation';
              
              // Dispatch cancel order event
              // context.read<OrderBloc>().add(CancelOrder(orderId, reason));
              
              Navigator.pop(context); // Close dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );
  }
} 