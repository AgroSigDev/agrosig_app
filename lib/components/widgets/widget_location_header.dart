import 'package:flutter/material.dart';
import '../../domain/services/plot_services/plot_services.dart';

class LocationHeader extends StatefulWidget {
  @override
  State<LocationHeader> createState() => _LocationHeaderState();
}

class _LocationHeaderState extends State<LocationHeader> {
  final PlotServices _plotServices = PlotServices();
  String _location = "Cargando ubicación...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (_isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.location_on_outlined, color: Colors.black54),
            SizedBox(width: 8),
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
        Icon(Icons.notifications_none, color: Colors.black54),
      ],
    );
  }
}