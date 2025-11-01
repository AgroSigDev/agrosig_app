import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/services/plot_services/plot_services.dart';
import '../../controller/provider/notification_provider.dart';
import '../../screens/notifications/notifications_screen.dart';

class LocationHeader extends ConsumerStatefulWidget {
  final VoidCallback? onNotificationTap;

  const LocationHeader({super.key, this.onNotificationTap});

  @override
  ConsumerState<LocationHeader> createState() => _LocationHeaderState();
}

class _LocationHeaderState extends ConsumerState<LocationHeader> {
  final PlotServices _plotServices = PlotServices();
  String _location = "Cargando ubicación...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadUnreadCount();
    });
  }

  Future<void> _loadUserLocation() async {
    try {
      final response = await _plotServices.getPlotCoordinates();

      if (response.success && response.data.isNotEmpty) {
        final plot = response.data.first;
        setState(() {
          _location = plot.location.isNotEmpty
              ? plot.location
              : "Ubicación no especificada";
          _isLoading = false;
        });
      } else {
        setState(() {
          _location = "No hay parcelas registradas";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading location: $e');
      setState(() {
        _location = "Error al cargar ubicación";
        _isLoading = false;
      });
    }
  }

  void _handleNotificationTap() {
    if (widget.onNotificationTap != null) {
      widget.onNotificationTap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
      ).then((_) {
        ref.read(notificationProvider.notifier).loadUnreadCount();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadCountProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.location_on_outlined, color: Colors.black54),
            const SizedBox(width: 8),
            Text(
              _location,
              style: TextStyle(
                fontSize: 16,
                color: _isLoading ? Colors.grey : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // Badge de notificaciones mejorado
        GestureDetector(
          onTap: _handleNotificationTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: Colors.grey[700],
                ),
                // Badge superpuesto mejorado
                if (unreadCount > 0) ...[
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5757), Color(0xFFC20808)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}