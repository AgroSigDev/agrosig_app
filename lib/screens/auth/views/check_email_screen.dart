import 'dart:io';
import 'package:agrosig/screens/auth/views/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import '../../../components/animations/animation_route.dart';
import '../../../components/boton/btn_agrosig.dart';
import '../../../components/custom/text_custom.dart';
import '../../../components/theme/colors_agrosig.dart';

class CheckEmailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 90.0),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.only(top: 50.0),
                      height: 110,
                      width: 110,
                      decoration: BoxDecoration(
                          color: ColorsAgrosig.primaryColor.withOpacity(.1),
                          borderRadius: BorderRadius.circular(20.0)
                      ),
                      child: const Icon(FontAwesomeIcons.envelopeOpenText, size: 60, color: ColorsAgrosig.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const TextCustom(text: 'Check your mail', textAlign: TextAlign.center, fontSize: 32, fontWeight: FontWeight.w500 ),
                  const SizedBox(height: 20.0),
                  const TextCustom(text: 'We have sent password recovery instructions to your email.', maxLine: 2, textAlign: TextAlign.center),
                  const SizedBox(height: 40.0),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 70.0),
                    child: BtnAgrosig(
                      text: 'Open email app',
                      fontWeight: FontWeight.w500,
                      onPressed: () async {
                        if (Platform.isAndroid) {
                          final intent = AndroidIntent(
                            action: 'android.intent.action.MAIN',
                            category: 'android.intent.category.APP_EMAIL',
                            flags: [
                              Flag.FLAG_ACTIVITY_NEW_TASK,   // Evita que se cree una nueva instancia de la app
                              Flag.FLAG_ACTIVITY_CLEAR_TOP, // Al volver, no crea otra pantalla encima
                            ],
                          );
                          await intent.launch();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 70.0),
                    child: InkWell(
                      onTap: () => Navigator.pushReplacement(context, routeAgroSig(page: SignInScreen())),
                      child: const TextCustom(text: 'Skip, I\'ll confirm later'),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 15.0),
                child: const TextCustom(
                  text: 'Did not receive the email? Check your spam filter.',
                  color: Colors.grey,
                  maxLine: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
