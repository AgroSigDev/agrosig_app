import 'dart:io';
import 'package:agrosig/domain/services/notifications_services/firebase_messaging_service.dart';
import 'package:agrosig/screens/into/into_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'components/theme/theme_notifier.dart';
import 'components/theme/themes.dart';
import 'controller/routers/routes.dart';
import 'controller/splace_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  await FirebaseMessagingService().initialize();

  runApp(
      ProviderScope(child: MyApp())
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    SplaceController splaceController = Get.put(SplaceController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      builder: FToastBuilder(),
      title: 'AgroSig IA',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      getPages: pages,
      home: const IntoScreen(),
    );
  }
}
