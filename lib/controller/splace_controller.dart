import 'package:get/get.dart';
import '../screens/auth/views/sign_in_screen.dart';

class SplaceController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    pageHander();
  }

  void pageHander() async {
    Future.delayed(
        const Duration(seconds: 6),
            () {
          Get.offAll(() => SignInScreen());
          update();
        }
    );
  }
}