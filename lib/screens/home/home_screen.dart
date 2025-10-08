import 'package:agrosig/components/widgets/widget_view_carrusel.dart';
import 'package:agrosig/screens/gemeni_ia/ia_onbording_screen.dart';
import 'package:flutter/material.dart';
import '../../components/boton/btn_navbar.dart';
import '../../components/widgets/widget_chatbot_card.dart';
import '../../components/widgets/widget_location_header.dart';
import '../../components/widgets/widget_mothtly_progress.dart';
import '../../components/widgets/widget_task_secction.dart';
import '../../components/widgets/widget_weather_card.dart';
import '../../components/widgets/widget_weekly_summary.dart';
import '../settings/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _getPageContent(int index) {
    switch (index) {
      case 0:
      // Página principal
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocationHeader(),
            const SizedBox(height: 20),
            WeatherCard(),
            const SizedBox(height: 16),
            IAChatbotCard(),
            const SizedBox(height: 24),
            ViewCarousel(),
            const SizedBox(height: 24),
            TasksToDoSection(),
            const SizedBox(height: 24),
            const WeeklySummaryWidget(),
            const MonthlyProgressWidget(),
          ],
        );
      case 1:
        return const Center(child: Text('Página de Tareas', style: TextStyle(fontSize: 24)));
      case 2:
        return const Center(child: Text('Página de Notificaciones', style: TextStyle(fontSize: 24)));
      case 3:
        return SettingsPage();
      default:
        return const Center(child: Text('Página Desconocida'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _getPageContent(_selectedIndex),
        ),
      ),
    );
  }
}
