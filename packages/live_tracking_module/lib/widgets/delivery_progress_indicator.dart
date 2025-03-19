import 'package:flutter/material.dart';
import 'package:live_tracking_module/models/tracking_data.dart';

/// A widget that displays the delivery progress as a step indicator
class DeliveryProgressIndicator extends StatelessWidget {
  /// The tracking data to display
  final TrackingData trackingData;
  
  /// Whether to show detailed information for each step
  final bool showDetails;
  
  const DeliveryProgressIndicator({
    super.key,
    required this.trackingData,
    this.showDetails = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildProgressSteps(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressSteps(BuildContext context) {
    // Define all possible statuses in order
    final statuses = [
      TrackingStatus.orderPlaced,
      TrackingStatus.driverToRestaurant,
      TrackingStatus.driverAtRestaurant,
      TrackingStatus.driverToCustomer,
      TrackingStatus.driverAtCustomer,
      TrackingStatus.delivered,
    ];
    
    // Find the current status index
    final currentStatusIndex = statuses.indexOf(trackingData.status);
    final isCanceled = trackingData.status == TrackingStatus.canceled;
    
    return Column(
      children: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final isCompleted = index <= currentStatusIndex && !isCanceled;
        final isCurrent = index == currentStatusIndex && !isCanceled;
        
        return _buildStep(
          context: context,
          status: status,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isCanceled: isCanceled && index > 0,
          isLast: index == statuses.length - 1,
        );
      }),
    );
  }
  
  Widget _buildStep({
    required BuildContext context,
    required TrackingStatus status,
    required bool isCompleted,
    required bool isCurrent,
    required bool isCanceled,
    required bool isLast,
  }) {
    final stepColor = isCanceled 
        ? Colors.red 
        : isCompleted 
            ? Theme.of(context).primaryColor 
            : Colors.grey;
    
    // Define icons for each status
    final IconData stepIcon;
    switch (status) {
      case TrackingStatus.orderPlaced:
        stepIcon = Icons.receipt;
        break;
      case TrackingStatus.driverToRestaurant:
        stepIcon = Icons.directions_car;
        break;
      case TrackingStatus.driverAtRestaurant:
        stepIcon = Icons.restaurant;
        break;
      case TrackingStatus.driverToCustomer:
        stepIcon = Icons.local_shipping;
        break;
      case TrackingStatus.driverAtCustomer:
        stepIcon = Icons.home;
        break;
      case TrackingStatus.delivered:
        stepIcon = Icons.check_circle;
        break;
      case TrackingStatus.canceled:
        stepIcon = Icons.cancel;
        break;
    }
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle and line
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCurrent 
                        ? stepColor 
                        : isCompleted 
                            ? stepColor 
                            : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: stepColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    stepIcon,
                    color: isCurrent || isCompleted 
                        ? Colors.white 
                        : stepColor,
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? stepColor : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 8,
                bottom: isLast ? 0 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.displayName,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent 
                          ? Theme.of(context).primaryColor 
                          : isCompleted 
                              ? Colors.black 
                              : Colors.grey,
                    ),
                  ),
                  if (showDetails && status != TrackingStatus.orderPlaced)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          _getStepDescription(status),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (isCurrent && trackingData.estimatedTimeOfArrival != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'ETA: ${trackingData.estimatedTimeOfArrival} min',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
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
  
  String _getStepDescription(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.orderPlaced:
        return 'Your order has been placed and is being processed';
      case TrackingStatus.driverToRestaurant:
        return 'Driver is headed to the restaurant to pick up your order';
      case TrackingStatus.driverAtRestaurant:
        return 'Driver has arrived at the restaurant and is picking up your order';
      case TrackingStatus.driverToCustomer:
        return 'Driver has your order and is headed to your location';
      case TrackingStatus.driverAtCustomer:
        return 'Driver has arrived at your location';
      case TrackingStatus.delivered:
        return 'Order has been delivered. Enjoy your meal!';
      case TrackingStatus.canceled:
        return 'Your order has been canceled';
    }
  }
} 