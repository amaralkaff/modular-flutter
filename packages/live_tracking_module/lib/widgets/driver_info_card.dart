import 'package:flutter/material.dart';
import 'package:live_tracking_module/models/tracking_data.dart';

/// A widget that displays information about the driver
class DriverInfoCard extends StatelessWidget {
  /// The tracking data containing driver information
  final TrackingData trackingData;
  
  const DriverInfoCard({
    super.key,
    required this.trackingData,
  });
  
  @override
  Widget build(BuildContext context) {
    // Only show card if driver location is available
    if (trackingData.driverLocation == null) {
      return const SizedBox.shrink();
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Driver avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Driver info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Driver',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Id: ${trackingData.driverLocation!.entityId}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                // Contact buttons
                _ContactButton(
                  icon: Icons.phone,
                  tooltip: 'Call driver',
                  onPressed: () {
                    // TODO: Implement call functionality in a real app
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Call functionality would be implemented here'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _ContactButton(
                  icon: Icons.message,
                  tooltip: 'Message driver',
                  onPressed: () {
                    // TODO: Implement messaging functionality in a real app
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Messaging functionality would be implemented here'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            // Show current status with ETA if available
            if (trackingData.estimatedTimeOfArrival != null &&
                (trackingData.status == TrackingStatus.driverToRestaurant ||
                 trackingData.status == TrackingStatus.driverToCustomer))
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      trackingData.status == TrackingStatus.driverToRestaurant
                          ? Icons.restaurant
                          : Icons.home,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trackingData.status == TrackingStatus.driverToRestaurant
                            ? 'Picking up your order'
                            : 'Delivering to you',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      'ETA: ${trackingData.estimatedTimeOfArrival} min',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A circular button for contacting the driver
class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  
  const _ContactButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed,
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }
} 