import 'dart:io';
import 'package:agrosig/domain/services/user_services/user_services.dart';
import 'package:agrosig/screens/settings/edit_parcel_screen.dart';
import 'package:agrosig/screens/settings/help_screen.dart';
import 'package:agrosig/screens/settings/terms_conditions_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/animations/animation_route.dart';
import '../../components/custom/text_custom.dart';
import '../../components/helper/modal_picture.dart';
import '../../components/item_account.dart';
import '../../components/toast/toats.dart';
import '../../data/local_secure/secure_storage.dart';
import '../../domain/models/user/user_model.dart';
import '../../domain/services/firebase_service/google_services.dart';
import '../../domain/services/auth_services/auth_services.dart';
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
  final AuthServices _authServices = AuthServices();
  User? _user;
  bool _isLoading = true;
  bool _isUpdatingImage = false;
  File? _selectedImage;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _loadUserData() async {
    try {
      _safeSetState(() {
        _isLoading = true;
      });

      final user = await _userServices.getUserProfile();
      _safeSetState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      _safeSetState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error al cargar datos del usuario: $e');
    }
  }

  Future<void> _handleImageSelection(File image) async {
    _safeSetState(() {
      _selectedImage = image;
      _isUpdatingImage = true;
    });

    try {
      final updatedUser = await _userServices.updateProfileImage(image);
      _safeSetState(() {
        _user = updatedUser;
        _isUpdatingImage = false;
        _selectedImage = null;
      });
      _showSuccessSnackBar('Imagen de perfil actualizada correctamente');
    } catch (e) {
      _safeSetState(() {
        _isUpdatingImage = false;
        _selectedImage = null;
      });
      _showErrorSnackBar('Error al actualizar imagen: $e');
    }
  }

  Future<void> _showImagePicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Seleccionar imagen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey.shade300),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.photo_library, color: Colors.blue.shade700),
                  ),
                  title: const Text(
                    'Galería',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _selectImage(ImageSource.gallery);
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade300),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.photo_camera, color: Colors.green.shade700),
                  ),
                  title: const Text(
                    'Cámara',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _selectImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null && mounted) {
        await _handleImageSelection(File(image.path));
      } else {
        showToast(message: 'No se seleccionó imagen');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al seleccionar imagen: ${e.toString()}');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header con avatar y información
            _buildProfileHeader(),
            const SizedBox(height: 32.0),
            // Sección de cuenta
            _buildAccountSection(),
            const SizedBox(height: 24.0),
            // Sección personal
            _buildPersonalSection(),
            const SizedBox(height: 24.0),
            // Botón de cerrar sesión
            _buildSignOutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              _buildProfileAvatar(),
              _buildEditIcon(),
            ],
          ),
          const SizedBox(height: 20),
          _buildUserName(),
          const SizedBox(height: 8),
          _buildUserEmail(),
          const SizedBox(height: 16),
          _buildUserRole(),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.blue.shade100,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: _isUpdatingImage && _selectedImage != null
            ? Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: 150,
          height: 150,
        )
            : _user?.image_user != null && _user!.image_user!.isNotEmpty
            ? _buildNetworkImage()
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildNetworkImage() {
    final imageUrl = _userServices.getImageUrl(_user!.image_user);

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: 150,
      height: 150,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildDefaultAvatar();
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey.shade100,
      child: Icon(
        Icons.person,
        size: 70,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildEditIcon() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: GestureDetector(
        onTap: _isUpdatingImage ? null : _showImagePicker,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4772E6), Color(0xFF1B83F5)],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: _isUpdatingImage
              ? const Padding(
            padding: EdgeInsets.all(10.0),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildUserName() {
    return Column(
      children: [
        Text(
          _user != null ? _formatUserName() : 'Nombre de Usuario',
          style: const TextStyle(
            fontSize: 24, // Aumentado
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E1E),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildUserEmail() {
    return Text(
      _user?.email ?? 'correo@ejemplo.com',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.grey.shade600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUserRole() {
    final role = _user?.role_id == 1 ? 'Administrador' : 'Usuario';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _user?.role_id == 1 ? Colors.orange.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _user?.role_id == 1 ? Colors.orange.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _user?.role_id == 1 ? Colors.orange.shade700 : Colors.blue.shade700,
        ),
      ),
    );
  }

  String _formatUserName() {
    if (_user == null) return '';

    final names = [
      _user!.first_name,
      _user!.paternal_surname,
      _user!.maternal_surname,
    ].where((name) => name.isNotEmpty).toList();

    return names.join(' ');
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            'Cuenta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ItemAccount(
                  text: 'Configuración del perfil',
                  icon: Icons.person_outline,
                  colorIcon: 0xff01C58C,
                  onPressed: () async {
                    // Navegar y esperar a que regrese
                    await Navigator.push(
                      context,
                      routeAgroSig(page: EditProfileScreen()),
                    ).then((value) {
                      _loadUserData();
                    });
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                ItemAccount(
                  text: 'Cambiar contraseña',
                  icon: Icons.lock_outline,
                  colorIcon: 0xff1B83F5,
                  onPressed: () => Navigator.push(
                    context,
                    routeAgroSig(page: ChangePasswordScreen()),
                  ).then((value) {
                    _loadUserData();
                  }),
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                ItemAccount(
                  text: 'Modificar Parcela',
                  icon: Icons.map_rounded,
                  colorIcon: 0xFF357B25,
                  onPressed: () => Navigator.push(
                    context,
                    routeAgroSig(page: EditParcelScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            'Personal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Divider(height: 1, color: Colors.grey.shade100),
                ItemAccount(
                  text: 'Términos y condiciones',
                  icon: Icons.description_outlined,
                  colorIcon: 0xff458bff,
                  onPressed: () => Navigator.push(
                      context,
                      routeAgroSig(page: TermsAndConditionsScreen())
                  )
                ),
                Divider(height: 1, color: Colors.grey.shade100),
                ItemAccount(
                  text: 'Centro de ayuda',
                  icon: Icons.help_outline,
                  colorIcon: 0xff4772e6,
                  onPressed: () => Navigator.push(
                      context,
                      routeAgroSig(page: HelpScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ItemAccount(
          text: 'Cerrar sesión',
          icon: Icons.logout,
          colorIcon: 0xFFFF6A55,
          onPressed: _performLogout,
        ),
      ),
    );
  }

  Future<void> _performLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout,
                    color: Colors.red.shade600,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '¿Estás seguro de que quieres cerrar sesión?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _executeLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _executeLogout() async {
    try {
      final userId = await _secureStorageAgroSig.getUserId();

      if (userId != null) {
        await _authServices.logout();
      }

      await _firebaseAuthService.signOut();

      Get.offAll(() => SignInScreen());
    } catch (e) {
      print('Error durante logout: $e');
      await _secureStorageAgroSig.clearAllData();
      await _firebaseAuthService.signOut();
      Get.offAll(() => SignInScreen());
    }
  }
}