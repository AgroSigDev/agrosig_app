import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/animations/animation_route.dart';
import '../../components/custom/text_custom.dart';
import '../../components/item_account.dart';
import '../../config/keys.dart';
import '../../data/local_secure/secure_storage.dart';
import '../../domain/models/response/response_user/response_user_update.dart';
import '../../domain/services/firebase_service/google_services.dart';
import '../../domain/services/user_services/user_services.dart';
import '../auth/views/sign_in_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SecureStorageAgroSig _secureStorageAgroSig = SecureStorageAgroSig();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final UserServices _userServices = UserServices();
  UserUpdated? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userServices.getUserProfile();
      final token = await secureStorage.getRefreshToken();
      setState(() {
        _user = user as UserUpdated?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Opcional: Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos del usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      children: [
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 60,
          backgroundImage: _user?.image_user != null && _user!.image_user.isNotEmpty
              ? NetworkImage('${Environment.users}/uploads/users/${_user!.image_user}')
              : const AssetImage('assets/images/dummy-profile.png') as ImageProvider,
        ),
        const SizedBox(height: 16),
        Center(
          child: TextCustom(
            text: _user != null
                ? '${_user!.firstName} ${_user!.lastName}'
                : 'Nombre de Usuario',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextCustom(
            text: _user?.email ?? 'correo@ejemplo.com',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30.0),
        Align(
          alignment: Alignment.topLeft,
          child: TextCustom(
            text: 'Account',
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10.0),
        ItemAccount(
          text: 'Profile setting',
          icon: Icons.person,
          colorIcon: 0xff01C58C,
          onPressed: () => Navigator.push(
            context, routeAgroSig(page: EditProfileScreen()),
          ),
        ),
        ItemAccount(
          text: 'Change Password',
          icon: Icons.lock_rounded,
          colorIcon: 0xff1B83F5,
          onPressed: () => Navigator.push(context, routeAgroSig(page: ChangePasswordScreen())),
        ),
        ItemAccount(
          text: 'Change Address',
          icon: Icons.map_rounded,
          colorIcon: 0xFFFE7B24,
          onPressed: () => (),
        ),
        ItemAccount(
          text: 'Dark Mode',
          icon: Icons.dark_mode_rounded,
          colorIcon: 0xff051E2F,
          onPressed: () => (),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: TextCustom(
            text: 'Personal',
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10.0),

        ItemAccount(
          text: 'Security',
          icon: Icons.lock_outline_rounded,
          colorIcon: 0xff1F252C,
          onPressed: () => (),
        ),
        ItemAccount(
          text: 'Term & Conditions',
          icon: Icons.description_outlined,
          colorIcon: 0xff458bff,
          onPressed: () => (),
        ),
        ItemAccount(
          text: 'Help',
          icon: Icons.help_outline,
          colorIcon: 0xff4772e6,
          onPressed: () => (),
        ),
        const Divider(),
        ItemAccount(
          text: 'Sign Out',
          icon: Icons.power_settings_new_sharp,
          colorIcon: 0xFFFF6A55,
          onPressed: _perfomLogout,
        ),
      ],
    );
  }

  Future<void> _perfomLogout() async {
    try {
      final userId = await secureStorage.getUserId();

      if (userId != null) {
        await _userServices.logout();
      }

      await _firebaseAuthService.signOut();

      Get.offAll(() => SignInScreen());
    } catch (e) {
      print('Error durante logout: $e');
      await secureStorage.clearAllData();
      await _firebaseAuthService.signOut();
      Get.offAll(() => SignInScreen());
    }
  }
}