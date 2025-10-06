import 'package:agrosig/screens/onboarding_plot/start_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../components/custom/text_custom.dart';
import '../../components/forms/form_fiel.dart';
import '../../components/helper/error_message.dart';
import '../../components/helper/modal_success.dart';
import '../../components/picker/map_picker.dart';
import '../../components/theme/colors_agrosig.dart';
import '../../components/toast/toats.dart';
import '../../domain/services/geocodig_services.dart';
import '../../domain/services/plot_services.dart';
import 'finish_setup_screen.dart';

class SettingPlotScreen extends StatefulWidget {
  @override
  _SettingPlotScreenState createState() => _SettingPlotScreenState();
}

class _SettingPlotScreenState extends State<SettingPlotScreen> {
  late TextEditingController _nameController;
  late TextEditingController _areaController;
  late TextEditingController _locationController; // ← Nuevo controller para ubicación
  final _keyForm = GlobalKey<FormState>();

  LatLng? _selectedLocation;
  String _coordinatesText = 'Select location on map';
  String _address = ''; // ← Dirección obtenida por geocodificación
  bool _isLoading = false;
  bool _isGettingAddress = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _areaController = TextEditingController();
    _locationController = TextEditingController();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showToast(message: 'Please enable location services');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showToast(message: 'Location permissions are denied');
      }
    }
  }

  Future<void> _selectLocation() async {
    try {
      final Position currentPosition = await Geolocator.getCurrentPosition();
      final LatLng? selected = await Get.to(
            () => MapPickerScreen(
          initialPosition: LatLng(
            currentPosition.latitude,
            currentPosition.longitude,
          ),
        ),
      );

      if (selected != null) {
        setState(() {
          _selectedLocation = selected;
          _coordinatesText = '${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}';
          _isGettingAddress = true;
        });

        // IMPORTANTE: Agregar await para esperar que termine
        await _getAddressFromCoordinates(selected);
      }
    } catch (e) {
      showToast(message: 'Error getting location: ${e.toString()}');
      setState(() {
        _isGettingAddress = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng coordinates) async {
    try {
      final address = await GeocodingService.getAddressFromLatLng(
        coordinates.latitude,
        coordinates.longitude,
      );

      setState(() {
        _address = address;
        _locationController.text = address;
        _isGettingAddress = false;
      });

    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _address = 'Unable to get address';
        _locationController.text = '';
        _isGettingAddress = false;
      });

      // Opcional: Mostrar mensaje al usuario
      showToast(message: 'Could not get address automatically. Please enter it manually.');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _areaController.clear();
    _locationController.clear();
    setState(() {
      _selectedLocation = null;
      _coordinatesText = 'Select location on map';
      _address = '';
    });
  }

  Future<void> _savePlot() async {
    if (_selectedLocation == null) {
      showToast(message: 'Please select a location on the map');
      return;
    }

    if (!_keyForm.currentState!.validate()) {
      showToast(message: 'Please complete all fields');
      return;
    }

    // Validar que tenemos una dirección
    if (_locationController.text.trim().isEmpty) {
      showToast(message: 'Please wait for address to load or enter location manually');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final areaText = _areaController.text.trim().replaceAll(',', '.');
      final area = double.tryParse(areaText);

      if (area == null || area <= 0) {
        showToast(message: 'Area must be a valid positive number');
        return;
      }

      final response = await plotServices.registerPlot(
        plotName: _nameController.text.trim(),
        location: _locationController.text.trim(), // ← Esta es la dirección automática
        lat: _selectedLocation!.latitude,
        long: _selectedLocation!.longitude,
        area: area,
      );

      if (response.success) {
        modalSuccess(context, 'Plot registered successfully', () {
          Get.offAll(() => FinishSetupPlot());
          _clearForm();
        });
      } else {
        errorMessageSnack(context, response.message);
      }
    } catch (e) {
      print('Error in _savePlot: $e');
      showToast(message: 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.offAll(() => StarSetupScreen()),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextCustom(
          text: "Set up your farm",
          color: ColorsAgrosig.titleLight,
          fontSize: 23,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _keyForm,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(value: 0.33),
                SizedBox(height: 20),
                Text(
                  "Create an account to access Fairm, and start to set up your farm and garden.",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 20.0),
                _buildLabel("Plot Name"),
                const SizedBox(height: 5.0),
                FormFieldAgro(
                  controller: _nameController,
                  hintText: "ex: Alex's Plot",
                  validator: RequiredValidator(errorText: 'Name is required'),
                ),
                SizedBox(height: 16.0),
                _buildLocationSection(),
                SizedBox(height: 16.0),
                _buildLabel("Area in m²"),
                const SizedBox(height: 5.0),
                FormFieldAgro(
                  controller: _areaController,
                  hintText: 'ex: 540',
                  keyboardType: TextInputType.number,
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'Area is required'),
                    PatternValidator(r'^[0-9]+(\.[0-9]+)?$',
                        errorText: 'Enter a valid number'),
                  ]),
                ),
                SizedBox(height: 40),
                _buildSavePlotButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Location"),
        const SizedBox(height: 5.0),

        // Botón para seleccionar ubicación en el mapa
        GestureDetector(
          onTap: _selectLocation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: ColorsAgrosig.greenColor),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select on Map',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: ColorsAgrosig.greenColor,
                        ),
                      ),
                      if (_coordinatesText != 'Select location on map') ...[
                        SizedBox(height: 4),
                        Text(
                          _coordinatesText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _isGettingAddress
                    ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Icon(Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade600),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Campo de texto para la dirección (se llena automáticamente)
        Text(
          'Address',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 5),
        FormFieldAgro(
          controller: _locationController,
          hintText: 'Address will be auto-filled from map selection',
          validator: RequiredValidator(errorText: 'Location address is required'),
          enabled: !_isGettingAddress, // Deshabilitar mientras se obtiene la dirección
        ),

        if (_isGettingAddress) ...[
          SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                'Getting address...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],

        if (_address.isNotEmpty && !_isGettingAddress) ...[
          SizedBox(height: 8),
          Text(
            'Detected address: $_address',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSavePlotButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (_isLoading || _isGettingAddress) ? null : _savePlot,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsAgrosig.greenColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        )
            : Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}