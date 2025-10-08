import 'package:agrosig/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../components/theme/colors_agroSig.dart';
import '../../components/theme/theme_notifier.dart';
import 'message_screen.dart';

class IAOnbording extends ConsumerStatefulWidget {
  const IAOnbording({Key? key}) : super(key: key);

  @override
  _IAOnbordingState createState() => _IAOnbordingState();
}

class _IAOnbordingState extends ConsumerState<IAOnbording> {

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final isDarkMode = currentTheme == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : ColorsAgrosig.primaryColor,
            size: 20,
          ),
          onPressed: (){
            Get.offAll(() => HomeScreen());
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 10),
            Row(
              children: [
                Image.asset(
                  'assets/images/gpt-robot.png',
                  color: isDarkMode ? Colors.white : null,
                ),
                const SizedBox(width: 10),
                Text(
                  'Gemini Gpt',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                )
              ],
            ),
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              onTap: (){
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'Your AI Assistant',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Using this software, you can ask questions and receive articles using artificial intelligence assistant',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),
            Image.asset('assets/images/onboarding.png'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: (){
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MessageScreen()),
                            (route) => false
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: ColorsAgrosig.backgroundColor,
                          size: 20
                      )
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}