import 'package:agrosig/screens/auth/views/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/animations/animation_route.dart';
import '../../../components/boton/btn_agrosig.dart';
import '../../../components/custom/text_custom.dart';
import '../../../components/forms/form_fiel.dart';
import '../../../components/helper/validate_form.dart';
import '../../../components/theme/colors_agrosig.dart';
import '../../../components/toast/toats.dart';
import 'check_email_screen.dart';


class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.clear();
    _emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context){

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const TextCustom(text: 'Reset Password', fontSize: 21, fontWeight: FontWeight.w500 ),
        centerTitle: true,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () => Navigator.pushReplacement(context, routeAgroSig(page: SignInScreen())),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: ColorsAgrosig.primaryColor ),
              TextCustom(text: 'Back', color: ColorsAgrosig.primaryColor, fontSize: 16)
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            children: [
              const TextCustom(
                text: 'Enter the email associated with your account and well send an email with instruccions to reset your password.',
                maxLine: 4,
                color: Colors.grey,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              const TextCustom(text: 'Email Address'),
              const SizedBox(height: 5.0),
              FormFieldAgro(
                controller: _emailController,
                hintText: 'example@frave.com',
                validator: validatedEmail,
              ),
              const SizedBox(height: 30.0),
              BtnAgrosig(
                text: 'Send',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                onPressed: (){
                  PasswordReset();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void PasswordReset() async {

    String email = await _emailController.text;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      showToast(message: "A message has been sent to your email");
      Get.offAll(() => CheckEmailScreen());

    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text (e.message.toString()),
            );
          }
      );
    }
  }
}