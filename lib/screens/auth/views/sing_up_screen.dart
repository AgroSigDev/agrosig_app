import 'dart:io';
import 'package:agrosig/screens/auth/views/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../components/custom/text_custom.dart';
import '../../../components/forms/form_fiel.dart';
import '../../../components/helper/error_message.dart';
import '../../../components/helper/modal_picture.dart';
import '../../../components/helper/modal_success.dart';
import '../../../components/helper/validate_form.dart';
import '../../../components/theme/colors_agrosig.dart';
import '../../../components/toast/toats.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../../domain/services/user_services.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _paternalSurnameController;
  late TextEditingController _maternalSurnameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  XFile? _selectedImage;

  final _keyForm = GlobalKey<FormState>();

  final secureStorage = SecureStorageAgroSig();

  @override
  void initState() {
    _firstNameController = TextEditingController();
    _paternalSurnameController = TextEditingController();
    _maternalSurnameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _paternalSurnameController.dispose();
    _maternalSurnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void clearForm() {
    _firstNameController.clear();
    _paternalSurnameController.clear();
    _maternalSurnameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  bool isSigningUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Get.offAll(() => SignInScreen());
          },
          child: Container(
            alignment: Alignment.center,
            child: const TextCustom(
              text: 'Log In',
              color: ColorsAgrosig.primaryColor,
              fontSize: 15,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        title: TextCustom(
          text: "Create a Account",
          color: ColorsAgrosig.primaryColor,
          fontSize: 18,
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: isSigningUp ? null : _registerUser,
            child: Container(
              margin: const EdgeInsets.only(right: 10.0),
              alignment: Alignment.center,
              child: isSigningUp
                  ? CircularProgressIndicator(color: ColorsAgrosig.primaryColor)
                  : const TextCustom(
                text: 'Save',
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
            Align(
              alignment: Alignment.center,
              child: _PictureRegistre(
                onImageSelected: (XFile? image) {
                  setState(() {
                    _selectedImage = image;
                  });
                },
              ),
            ),
            const SizedBox(height: 20.0),
            const TextCustom(text: "First Name"),
            const SizedBox(height: 5.0),
            FormFieldAgro(
              controller: _firstNameController,
              hintText: 'Enter your first name',
              validator: RequiredValidator(errorText: 'First name is required'),
            ),
            const SizedBox(height: 15.0),
            const TextCustom(text: 'Paternal Surname'),
            const SizedBox(height: 5.0),
            FormFieldAgro(
              controller: _paternalSurnameController,
              hintText: 'Enter your paternal surname',
              validator: RequiredValidator(errorText: 'Paternal surname is required'),
            ),
            const SizedBox(height: 15.0),
            const TextCustom(text: 'Maternal Surname'),
            const SizedBox(height: 5.0),
            FormFieldAgro(
              controller: _maternalSurnameController,
              hintText: 'Enter your maternal surname',
              validator: RequiredValidator(errorText: 'Maternal surname is required'),
            ),
            const SizedBox(height: 15.0),
            const TextCustom(text: 'Email'),
            const SizedBox(height: 5.0),
            FormFieldAgro(
              controller: _emailController,
              hintText: 'email@agrosig.com',
              keyboardType: TextInputType.emailAddress,
              validator: validatedEmail,
            ),
            const SizedBox(height: 15.0),
            const TextCustom(text: 'Password'),
            const SizedBox(height: 5.0),
            FormFieldAgro(
              controller: _passwordController,
              hintText: '********',
              isPassword: true,
              validator: passwordValidator,
            ),
            const SizedBox(height: 30.0),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: isSigningUp ? null : _registerUser,
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          color: ColorsAgrosig.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isSigningUp
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
            "Register",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    if (_keyForm.currentState!.validate()) {
      setState(() => isSigningUp = true);

      final firstName = _firstNameController.text.trim();
      final paternalSurname = _paternalSurnameController.text.trim();
      final maternalSurname = _maternalSurnameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final imagePath = _selectedImage?.path;

      try {
        final response = await userServices.registerUser(
          firstName,
          paternalSurname,
          maternalSurname,
          imagePath,
          email,
          password,
        );

        if (response.resp) {
          modalSuccess(context, 'User Registered Successfully', () {
            Get.offAll(() => SignInScreen());
            clearForm();
          });
        } else {
          errorMessageSnack(context, response.msg);
        }
      } catch (e) {
        showToast(message: 'Error: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() => isSigningUp = false);
        }
      }
    }
  }
}

class _PictureRegistre extends StatefulWidget {
  final Function(XFile?) onImageSelected;

  const _PictureRegistre({Key? key, required this.onImageSelected}) : super(key: key);

  @override
  _PictureRegistreState createState() => _PictureRegistreState();
}

class _PictureRegistreState extends State<_PictureRegistre> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });

      widget.onImageSelected(_imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () => modalPictureRegister(
        ctx: context,
        onPressedChange: () => _pickImage(ImageSource.gallery),
        onPressedTake: () => _pickImage(ImageSource.camera),
      ),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          border: Border.all(style: BorderStyle.solid, color: Colors.grey[300]!),
          shape: BoxShape.circle,
          image: _imageFile != null
              ? DecorationImage(
            image: FileImage(File(_imageFile!.path)),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: _imageFile == null
            ? Icon(Icons.camera_alt, color: Colors.grey, size: 50)
            : null,
      ),
    );
  }
}