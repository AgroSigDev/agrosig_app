import 'package:flutter/material.dart';

class WeeklySummaryWidget extends StatelessWidget {
  const WeeklySummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen Semanal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: '💧',
                value: '1,200L',
                label: 'Agua usada',
                onTap: () {
                  // Navegar a pantalla de estadísticas de agua
                  print('Navegar a estadísticas de agua');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                icon: '🌱',
                value: '3',
                label: 'Cultivos activos',
                onTap: () {
                  // Navegar a pantalla de cultivos
                  print('Navegar a cultivos');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                icon: '💰',
                value: '\$450',
                label: 'Costos del mes',
                onTap: () {
                  // Navegar a pantalla de costos
                  print('Navegar a costos');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String icon,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[100]!),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}