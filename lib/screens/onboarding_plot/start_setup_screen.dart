import 'dart:ffi';
import 'package:agrosig/screens/onboarding_plot/setting_plot_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../data/local_secure/secure_storage.dart';
import '../../domain/services/firebase_service/google_services.dart';
import '../../domain/services/auth_services/auth_services.dart';
import '../auth/views/sign_in_screen.dart';

class StarSetupScreen extends StatefulWidget {
  const StarSetupScreen({super.key});

  @override
  _StarSetupScreen createState() => _StarSetupScreen();
}

class _StarSetupScreen extends State<StarSetupScreen> {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final AuthServices _userServices = AuthServices();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/farm_background.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.4)
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // LOGO
                  Center(
                    child: Container(
                      height: 60,
                      width: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 120,
                          backgroundImage: AssetImage('assets/images/logo.png'),

                          backgroundColor: Colors.transparent,
                        ),
                        //child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // INFO CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tomatoes Field", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _infoItem("Crop Health", "Good"),
                            _infoItem("Planting date", "12/01/2024"),
                            _infoItem("Harvest time", "~4 Months"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Let's Start Setting Up Your Farm",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Hi First Name, let’s start working on your farm settings.\nSo you can know more about it with the help of AI",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // ONLY THIS BUTTON BELOW TEXT
                  GestureDetector(
                    onTap: () {
                      Get.to(() => SettingPlotScreen());
                    },
                    child: _buildStarButton(),
                  ),
                  SizedBox(height: 10),
                  _buildSetLater(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStarButton() {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(FontAwesomeIcons.leaf, color: Colors.white),
            SizedBox(width: 5),
            Text(
              "Get Started",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetLater(){
    return GestureDetector(
      onTap: _performLogout,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.mail_outline),
          SizedBox(width: 8),
          Text("Set up later"),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      final userId = await secureStorage.getUserId();

      if (userId != null) {
        await _userServices.logout();
      }

      // Cerrar sesión en Firebase si es necesario
      await _firebaseAuthService.signOut();

      // Redirigir a la pantalla de login
      Get.offAll(() => SignInScreen());

    } catch (e) {
      print('Error durante logout: $e');
      // Asegurar limpieza incluso con errores
      await secureStorage.clearAllData();
      await _firebaseAuthService.signOut();
      Get.offAll(() => SignInScreen());
    }
  }
}
