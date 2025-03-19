import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:orders_module/bloc/order_bloc.dart';
import 'package:orders_module/bloc/order_event.dart';
import 'package:orders_module/bloc/order_state.dart';
import 'package:orders_module/models/order_model.dart' as order_model;

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadOrderDetails(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderDetailsLoaded) {
            return _buildTrackingContent(context, state.order);
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
                    onPressed: () {
                      context
                          .read<OrderBloc>()
                          .add(LoadOrderDetails(widget.orderId));
                    },
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
    );
  }

  Widget _buildTrackingContent(BuildContext context, order_model.Order order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                    'From: ${order.restaurantName}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (order.estimatedDeliveryTime != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Estimated delivery: ${DateFormat('hh:mm a').format(order.estimatedDeliveryTime!)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Status Updates',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildTrackingTimeline(context, order),
          const SizedBox(height: 24),
          Text(
            'Delivery Address',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          if (order.status != order_model.OrderStatus.delivered &&
              order.status != order_model.OrderStatus.cancelled)
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Refresh order details
                  context
                      .read<OrderBloc>()
                      .add(LoadOrderDetails(widget.orderId));
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order status refreshed'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
              ),
            ),
          if (order.status == order_model.OrderStatus.pending ||
              order.status == order_model.OrderStatus.preparing)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton.icon(
                  onPressed: () {
                    _showCancelOrderDialog(context, order.id);
                  },
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text(
                    'Cancel Order',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(BuildContext context, order_model.Order order) {
    // Define all possible statuses in order
    final allStatuses = [
      order_model.OrderStatus.pending,
      order_model.OrderStatus.preparing,
      order_model.OrderStatus.readyForPickup,
      order_model.OrderStatus.pickedUp,
      order_model.OrderStatus.inDelivery,
      order_model.OrderStatus.delivered,
    ];

    // Find the index of the current status
    final currentStatusIndex = allStatuses.indexOf(order.status);
    
    // If order is cancelled, show a different timeline
    if (order.status == order_model.OrderStatus.cancelled) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel, color: Colors.red),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Cancelled',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reason: ${order.cancellationReason ?? "N/A"}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cancelled on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(allStatuses.length, (index) {
            final status = allStatuses[index];
            final isCompleted = index <= currentStatusIndex;
            final isActive = index == currentStatusIndex;

            // Skip delivered status if order is not delivered
            if (status == order_model.OrderStatus.delivered && !isCompleted) {
              return const SizedBox.shrink();
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green
                            : Colors.grey.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: isActive
                            ? Border.all(color: Colors.green, width: 2)
                            : null,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    if (index < allStatuses.length - 1)
                      Container(
                        width: 2,
                        height: 40,
                        color: isCompleted
                            ? Colors.green
                            : Colors.grey.withOpacity(0.3),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.name,
                        style: TextStyle(
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? Colors.green : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _getStatusDescription(status),
                      SizedBox(height: index < allStatuses.length - 1 ? 20 : 0),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _getStatusDescription(order_model.OrderStatus status) {
    switch (status) {
      case order_model.OrderStatus.pending:
        return const Text('Your order has been received by the restaurant.');
      case order_model.OrderStatus.preparing:
        return const Text('The restaurant is preparing your food.');
      case order_model.OrderStatus.readyForPickup:
        return const Text('Your order is ready for pickup by the driver.');
      case order_model.OrderStatus.pickedUp:
        return const Text('The driver has picked up your order.');
      case order_model.OrderStatus.inDelivery:
        return const Text('Your order is on its way to you.');
      case order_model.OrderStatus.delivered:
        return const Text('Your order has been delivered. Enjoy!');
      case order_model.OrderStatus.cancelled:
        return const Text('This order has been cancelled.');
    }
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
              context.read<OrderBloc>().add(CancelOrder(orderId, reason));
              
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