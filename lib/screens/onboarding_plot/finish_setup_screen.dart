import 'package:agrosig/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/helper/modal_success.dart';
import '../../components/toast/toats.dart';
import '../../components/theme/colors_agrosig.dart';
import '../../domain/models/plot/plot_model.dart';
import '../../domain/services/plot_services/plot_services.dart';

class FinishSetupPlot extends StatefulWidget {
  const FinishSetupPlot({Key? key}) : super(key: key);

  @override
  _FinishSetupPlotState createState() => _FinishSetupPlotState();
}

class _FinishSetupPlotState extends State<FinishSetupPlot> {
  late TextEditingController _plotNameController;
  late TextEditingController _locationController;
  late TextEditingController _areaController;

  Plot? _userPlot;
  bool _isLoading = true;
  bool _isEditing = false;
  String _errorMessage ='';

  @override
  void initState() {
    super.initState();
    _plotNameController = TextEditingController();
    _locationController = TextEditingController();
    _areaController = TextEditingController();
    _loadUserPlot();
  }

  @override
  void dispose() {
    _plotNameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPlot() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final plot = await plotServices.getPlotByUserId();

      print('Plot loaded: $plot');

      setState(() {
        _userPlot = plot;
        if (plot != null) {
          _plotNameController.text = plot.plot_name;
          _locationController.text = plot.location;
          _areaController.text = plot.area.toString();
          print('Controllers set with: ${plot.plot_name}, ${plot.location}, ${plot.area}');
        } else {
          _errorMessage = 'No se encontró información de la parcela';
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user plot: $e');
      setState(() {
        _errorMessage = 'Error cargando datos: ${e.toString()}';
        _isLoading = false;
      });
      showToast(message: 'Error loading plot data');
    }
  }

  Future<void> _updatePlot() async {
    if (_userPlot == null) {
      showToast(message: 'No hay datos de parcela para actualizar');
      return;
    }

    if (_plotNameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _areaController.text.isEmpty) {
      showToast(message: 'Please fill all fields');
      return;
    }

    setState(() {
      _isEditing = true;
      _errorMessage = '';
    });

    try {
      final areaText = _areaController.text.trim().replaceAll(',', '.');
      final area = double.tryParse(areaText);

      if (area == null || area <= 0) {
        showToast(message: 'Area must be a valid positive number');
        return;
      }

      final response = await plotServices.updatePlot(
        plotId: _userPlot!.plot_id,
        plotName: _plotNameController.text,
        location: _locationController.text,
        lat: _userPlot!.lat,
        long: _userPlot!.long,
        area: area,
      );

      if (response.success) {
        modalSuccess(context, 'Plot updated successfully', () {
          Get.offAll(() => HomeScreen());
        });
      } else {
        setState(() {
          _errorMessage = response.message;
        });
        showToast(message: response.message);
      }
    } catch (e) {
      print('Error updating plot: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
      showToast(message: 'Error updating plot: ${e.toString()}');
    } finally {
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _goToHome() {
    Get.offAll(() => HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColorsAgrosig.greenColor),
              ),
              SizedBox(height: 20),
              Text('Cargando Informacion de la Parcela...')
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50),
              SizedBox(height: 20),
              Text('Error: $_errorMessage', textAlign: TextAlign.center),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadUserPlot,
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header con ícono de cerrar
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ColorsAgrosig.highlightLight,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: ColorsAgrosig.titleLight),
                      onPressed: () => Get.offAll(() => HomeScreen()),
                    ),
                  ),
                  Spacer(),
                ],
              ),

              const SizedBox(height: 30),

              // Ícono de éxito con sombra
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: ColorsAgrosig.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorsAgrosig.success.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 50,
                ),
              ),

              const SizedBox(height: 30),

              // Título
              Text(
                'Farm Set Up Successful!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: ColorsAgrosig.titleLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              // Descripción
              Text(
                'Your farm has been successfully configured. You can review and update the details below.',
                style: TextStyle(
                  fontSize: 16,
                  color: ColorsAgrosig.textLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Tarjeta de detalles de la parcela - CON SOMBRA PRONUNCIADA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: ColorsAgrosig.highlightLight,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la sección
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ColorsAgrosig.greenColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.agriculture_outlined,
                            color: ColorsAgrosig.greenColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Farm Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ColorsAgrosig.titleLight,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // Campo Plot Name
                    _buildDetailField(
                      label: 'Plot Name',
                      icon: Icons.badge_outlined,
                      controller: _plotNameController,
                      hintText: "ex: Michael's garden",
                    ),

                    SizedBox(height: 24),

                    // Campo Location
                    _buildDetailField(
                      label: 'Location',
                      icon: Icons.location_on_outlined,
                      controller: _locationController,
                      hintText: 'Plot location',
                    ),

                    SizedBox(height: 24),

                    // Campo Area
                    _buildDetailField(
                      label: 'Area (m²)',
                      icon: Icons.square_foot_outlined,
                      controller: _areaController,
                      hintText: 'Plot area',
                      isNumber: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Botón Update Plot
              Container(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsAgrosig.greenColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: ColorsAgrosig.greenColor.withOpacity(0.4),
                  ),
                  onPressed: _isEditing ? null : _updatePlot,
                  child: _isEditing
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Update Farm Details',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Botón Go to Home
              Container(
                width: double.infinity,
                height: 58,
                child: OutlinedButton.icon(
                  icon: Icon(Icons.home_outlined, size: 22),
                  label: Text(
                    'Go to Home',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: ColorsAgrosig.greenColor, width: 2.5),
                    foregroundColor: ColorsAgrosig.greenColor,
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: _goToHome,
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ColorsAgrosig.greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: ColorsAgrosig.greenColor, size: 18),
            ),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ColorsAgrosig.titleLight,
                fontSize: 15,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 54,
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: ColorsAgrosig.textGrey),
              contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: ColorsAgrosig.highlightLight, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: ColorsAgrosig.highlightLight, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: ColorsAgrosig.greenColor, width: 2),
              ),
              filled: true,
              fillColor: ColorsAgrosig.bgLight,
            ),
            style: TextStyle(
              fontSize: 16,
              color: ColorsAgrosig.titleLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}