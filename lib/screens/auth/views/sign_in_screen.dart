import 'dart:convert';
import 'package:agrosig/screens/auth/views/sing_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../components/animations/animation_route.dart';
import '../../../components/custom/text_custom.dart';
import '../../../components/forms/form_fiel.dart';
import '../../../components/helper/error_message.dart';
import '../../../components/helper/validate_form.dart';
import '../../../components/theme/colors_agrosig.dart';
import '../../../components/toast/toats.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../../domain/services/user_services.dart';
import '../../home/home_screen.dart';
import '../../onboarding_plot/start_setup_screen.dart';
import 'forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  final _keyForm = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void clearForm() {
    _emailController.clear();
    _passwordController.clear();
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isSigning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Get.offAll(() => SignUpPage());
          },
          child: Container(
            alignment: Alignment.center,
            child: const TextCustom(
              text: 'Register',
              color: ColorsAgrosig.primaryColor,
              fontSize: 15,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        title: TextCustom(
          text: "Sign In",
          color: ColorsAgrosig.primaryColor,
          fontSize: 18,
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: isSigning ? null : _signInWithEmailPassword,
            child: Container(
              margin: const EdgeInsets.only(right: 10.0),
              alignment: Alignment.center,
              child: isSigning
                  ? CircularProgressIndicator(color: ColorsAgrosig.primaryColor)
                  : const TextCustom(
                text: 'Login',
                color: ColorsAgrosig.primaryColor,
                fontSize: 15,
              ),
            ),
          )
        ],
      ),
      body: Form(
        key: _keyForm,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          children: [
            const SizedBox(height: 20.0),
            Image.asset('assets/images/logo.png', height: 150),
            const SizedBox(height: 30.0),
            Container(
              alignment: Alignment.center,
              child: const TextCustom(
                text: 'Welcome back!',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Color(0xff14222E),
              ),
            ),
            const SizedBox(height: 5.0),
            const Align(
              alignment: Alignment.center,
              child: TextCustom(
                text: 'Use your credentials below and login to your account.',
                textAlign: TextAlign.center,
                color: Colors.grey,
                maxLine: 2,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 50.0),
            const TextCustom(text: 'Email Address'),
            const SizedBox(height: 5.0),
            FormFieldAgro(
              controller: _emailController,
              hintText: 'email@agrosig.com',
              keyboardType: TextInputType.emailAddress,
              validator: validatedEmail,
            ),
            const SizedBox(height: 20.0),
            const TextCustom(text: 'Password'),
            const SizedBox(height: 5.0),
            FormFieldAgro(
              controller: _passwordController,
              hintText: '********',
              isPassword: true,
              validator: passwordValidator,
            ),
            const SizedBox(height: 20.0),
            _buildLoginButton(),
            const SizedBox(height: 10.0),
            _buildGoogleSignInButton(),
            const SizedBox(height: 10.0),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Navigator.push(context, routeAgroSig(page: ResetPassword())),
                child: TextCustom(
                  text: 'Forgot Password?',
                  fontSize: 17,
                  color: ColorsAgrosig.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: isSigning ? null : _signInWithEmailPassword,
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          color: ColorsAgrosig.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isSigning
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
            "Login",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return GestureDetector(
      onTap: isSigning ? null : _signInWithGoogle,
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.google, color: Colors.white),
              SizedBox(width: 5),
              Text(
                "Sign in with Google",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithEmailPassword() async {
    if (!_keyForm.currentState!.validate()) {
      showToast(message: 'Por favor, completa todos los campos correctamente');
      return;
    }

    setState(() {
      isSigning = true;
    });

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        final response = await userServices.loginUser(email, password);

        // El login fue exitoso, los tokens se guardaron en SecureStorage
        showToast(message: 'Welcome to AgroSig');

        // Obtener el perfil del usuario para verificar si tiene parcela configurada
        final userProfile = response.user;

        if (userProfile.configured_plot) {
          Get.offAll(() => HomeScreen());
        } else {
          Get.offAll(() => StarSetupScreen());
        }

        clearForm();
      } catch (e) {
        print('Login Error: $e');
        showToast(message: 'Error: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            isSigning = false;
          });
        }
      }
    }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        await _googleSignIn.signOut();

        final GoogleSignInAccount? newGoogleSignInAccount = await _googleSignIn.signIn();

        if (newGoogleSignInAccount != null) {
          final GoogleSignInAuthentication googleSignInAuthentication =
          await newGoogleSignInAccount.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );
          final UserCredential authResult = await _auth.signInWithCredential(credential);
          final User? user = authResult.user;

          if (user != null) {
            showToast(message: "Signed in with Google successfully");
            // Aquí podrías integrar con tu backend para registrar/login con Google
            // Por ahora redirigimos a HomeScreen
            Get.offAll(() => HomeScreen());
          } else {
            showToast(message: "Error signing in with Google");
          }
        }
      }
    } catch (error) {
      print("Error signing in with Google: $error");
    }
  }
}