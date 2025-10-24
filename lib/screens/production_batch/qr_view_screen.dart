import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/models/production/activity_with_inputs_model.dart';
import '../../domain/services/production_services/production_services.dart';
import 'associate_activity_screen.dart';

class QRViewScreen extends StatefulWidget {
  final int productionId;
  final String batchName;

  const QRViewScreen({
    super.key,
    required this.productionId,
    required this.batchName,
  });

  @override
  State<QRViewScreen> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen> {
  final ProductionBatchService _productionBatchService = ProductionBatchService();
  String? _qrCode;
  bool _isLoading = true;
  bool _hasActivities = false;
  int _activityCount = 0;
  String _errorMessage = '';
  List<ActivityWithInputs> _activities = [];
  Uint8List? _qrImageBytes;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadQRData(),
      _loadActivities(),
    ]);
  }

  Future<void> _loadQRData() async {
    try {
      final response = await _productionBatchService.getProductionBatchDetail(widget.productionId);

      if (response.success) {
        setState(() {
          _qrCode = response.data.qrCode;
          _hasActivities = response.data.hasActivities;
          _activityCount = response.data.activityCount;
          _convertQRToImage();
        });
      } else {
        setState(() {
          _errorMessage = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos del QR: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _convertQRToImage() {
    if (_qrCode == null || _qrCode!.isEmpty) return;

    try {
      // Si el QR code es un data URI (base64), lo convertimos a bytes
      if (_qrCode!.startsWith('data:image')) {
        final String base64String = _qrCode!.split(',').last;
        _qrImageBytes = base64.decode(base64String);
      }
      // Si es una URL normal, dejamos _qrImageBytes como null y usaremos Image.network
      else if (_qrCode!.startsWith('http')) {
        _qrImageBytes = null;
      }
    } catch (e) {
      print('Error converting QR to image: $e');
      _qrImageBytes = null;
    }
  }

  Future<void> _loadActivities() async {
    try {
      final response = await _productionBatchService.getBatchActivities(widget.productionId);
      if (response.success) {
        setState(() {
          _activities = response.data;
          _activityCount = _activities.length;
          _hasActivities = _activities.isNotEmpty;
        });
      }
    } catch (e) {
      print('Error loading activities: $e');
    }
  }

  Future<void> _forceRefreshQR() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _productionBatchService.refreshQRCode(widget.productionId);

      if (response.success) {
        // Actualizar con los nuevos datos del QR
        setState(() {
          _qrCode = response.data?.qrCode;
          _convertQRToImage();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR regenerado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al regenerar QR: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAssociateActivities() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsociarActividadesScreen(productionId: widget.productionId),
      ),
    ).then((_) {
      _loadAllData();
    });
  }

  void _shareQRCode() {
    if (_qrCode == null || _qrCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay código QR para compartir')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de compartir no implementada')),
    );
  }

  Widget _buildQRImage() {
    if (_qrImageBytes != null) {
      // Si tenemos bytes (data URI), usamos Image.memory
      return Image.memory(
        _qrImageBytes!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else if (_qrCode != null && _qrCode!.startsWith('http')) {
      // Si es una URL HTTP, usamos Image.network
      return Image.network(
        _qrCode!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else {
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    return const Column(
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 48),
        SizedBox(height: 8),
        Text('Error al cargar QR'),
      ],
    );
  }

  Widget _buildNoActivitiesCard() {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            const Text(
              'No hay actividades asociadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.orange),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para generar el código QR, primero debes asociar actividades a este lote.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orange),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _navigateToAssociateActivities,
              icon: const Icon(Icons.add_task),
              label: const Text('Asociar Actividades'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratingQRCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Generando Código QR...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Lote: ${widget.batchName}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Actividades asociadas: $_activityCount',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              widget.batchName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '$_activityCount actividad(es) asociada(s)',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              'Código QR de Trazabilidad',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                width: 200,
                height: 200,
                child: _buildQRImage(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Escanea este código QR para ver la trazabilidad completa del producto',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _navigateToAssociateActivities,
            icon: const Icon(Icons.edit_note),
            label: Text(_hasActivities ? 'Gestionar Actividades' : 'Asociar Actividades'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (_qrCode != null && _hasActivities)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _shareQRCode,
              icon: const Icon(Icons.share, color: Colors.white,),
              label: const Text('Compartir', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A38C2),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Código QR - ${widget.batchName}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_hasActivities && _qrCode != null)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: _shareQRCode,
              tooltip: 'Compartir QR',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _forceRefreshQR,
            tooltip: 'Regenerar QR',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadAllData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (!_hasActivities) _buildNoActivitiesCard(),
            if (_hasActivities && _qrCode == null) _buildGeneratingQRCard(),
            if (_hasActivities && _qrCode != null) _buildQRCodeCard(),
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
}