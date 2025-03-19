import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:live_tracking_module/bloc/tracking_bloc.dart';
import 'package:live_tracking_module/bloc/tracking_state.dart';
import 'package:live_tracking_module/bloc/tracking_event.dart';
import 'package:live_tracking_module/models/tracking_data.dart';
import 'package:live_tracking_module/widgets/delivery_progress_indicator.dart';

/// Screen that displays detailed information about the delivery status
class DeliveryStatusScreen extends StatefulWidget {
  /// ID of the order to track
  final String orderId;
  
  const DeliveryStatusScreen({
    super.key,
    required this.orderId,
  });
  
  @override
  State<DeliveryStatusScreen> createState() => _DeliveryStatusScreenState();
}

class _DeliveryStatusScreenState extends State<DeliveryStatusScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TrackingBloc>().add(StartTrackingListenEvent(widget.orderId));
  }
  
  @override
  void dispose() {
    context.read<TrackingBloc>().add(StopTrackingListenEvent());
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'View Map',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/tracking-map',
                arguments: widget.orderId,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          if (state is TrackingInitial) {
            return const Center(child: Text('Initializing tracking...'));
          } else if (state is TrackingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TrackingActive || 
                    state is RouteCalculating || 
                    state is RouteCalculated ||
                    state is TrackingEnded) {
            final trackingData = 
                state is TrackingActive ? state.trackingData :
                state is RouteCalculating ? state.trackingData :
                state is RouteCalculated ? state.trackingData :
                (state as TrackingEnded).trackingData;
            
            return _buildDeliveryStatus(context, trackingData);
          } else if (state is TrackingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
  
  Widget _buildDeliveryStatus(BuildContext context, TrackingData trackingData) {
    final dateFormat = DateFormat('h:mm a');
    final estimatedDeliveryTime = trackingData.estimatedTimeOfArrival != null
        ? DateTime.now().add(Duration(minutes: trackingData.estimatedTimeOfArrival!))
        : null;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order status card
          _buildStatusCard(trackingData, estimatedDeliveryTime, dateFormat),
          
          const SizedBox(height: 24),
          
          // Progress timeline
          DeliveryProgressIndicator(
            trackingData: trackingData,
            showDetails: true,
          ),
          
          const SizedBox(height: 24),
          
          // Delivery info
          _buildInfoSection(
            title: 'Delivery Information',
            icon: Icons.info_outline,
            children: [
              _buildInfoRow(
                label: 'Order ID',
                value: trackingData.orderId,
              ),
              _buildInfoRow(
                label: 'Started At',
                value: dateFormat.format(trackingData.startTime),
              ),
              if (estimatedDeliveryTime != null)
                _buildInfoRow(
                  label: 'Estimated Delivery',
                  value: dateFormat.format(estimatedDeliveryTime),
                ),
              if (trackingData.estimatedTimeOfArrival != null)
                _buildInfoRow(
                  label: 'ETA',
                  value: '${trackingData.estimatedTimeOfArrival} min',
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Location info
          _buildInfoSection(
            title: 'Locations',
            icon: Icons.place,
            children: [
              _buildInfoRow(
                label: 'Restaurant',
                value: 'Lat: ${trackingData.restaurantLocation.latitude.toStringAsFixed(6)}\n'
                      'Lng: ${trackingData.restaurantLocation.longitude.toStringAsFixed(6)}',
              ),
              _buildInfoRow(
                label: 'Delivery Address',
                value: 'Lat: ${trackingData.customerLocation.latitude.toStringAsFixed(6)}\n'
                      'Lng: ${trackingData.customerLocation.longitude.toStringAsFixed(6)}',
              ),
              if (trackingData.driverLocation != null)
                _buildInfoRow(
                  label: 'Current Driver Location',
                  value: 'Lat: ${trackingData.driverLocation!.latitude.toStringAsFixed(6)}\n'
                        'Lng: ${trackingData.driverLocation!.longitude.toStringAsFixed(6)}',
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Route info
          if (trackingData.restaurantToCustomerRoute != null)
            _buildInfoSection(
              title: 'Route Details',
              icon: Icons.directions,
              children: [
                _buildInfoRow(
                  label: 'Distance',
                  value: trackingData.restaurantToCustomerRoute!.formattedDistance,
                ),
                _buildInfoRow(
                  label: 'Duration',
                  value: trackingData.restaurantToCustomerRoute!.formattedDuration,
                ),
              ],
            ),
          
          const SizedBox(height: 36),
          
          // View map button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/tracking-map',
                  arguments: widget.orderId,
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('View Live Map'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard(
    TrackingData trackingData,
    DateTime? estimatedDeliveryTime,
    DateFormat dateFormat,
  ) {
    final isCompleted = trackingData.status == TrackingStatus.delivered || 
                        trackingData.status == TrackingStatus.canceled;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.delivery_dining,
                  size: 32,
                  color: isCompleted
                      ? trackingData.status == TrackingStatus.delivered
                          ? Colors.green
                          : Colors.red
                      : Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trackingData.status.displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (!isCompleted && estimatedDeliveryTime != null)
                        Text(
                          'Estimated arrival: ${dateFormat.format(estimatedDeliveryTime)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isCompleted)
              Column(
                children: [
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        trackingData.estimatedTimeOfArrival != null
                            ? 'Arrives in ${trackingData.estimatedTimeOfArrival} minutes'
                            : 'Calculating ETA...',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
        ...children,
      ],
    );
  }
  
  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 