import 'package:flutter/material.dart';

class MonthlyProgressWidget extends StatelessWidget {
  const MonthlyProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Progreso Mensual',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        _buildProgressBar(
          label: 'Tareas',
          progress: 0.75,
          onTap: () {
            // Navegar a pantalla de tareas
            print('Navegar a tareas');
          },
        ),
        const SizedBox(height: 12),
        _buildProgressBar(
          label: 'Gastos',
          progress: 0.90,
          onTap: () {
            // Navegar a pantalla de gastos
            print('Navegar a gastos');
          },
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required String label,
    required double progress,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: progress * 100, // Esto se ajustará con lógica real después
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green[400]!,
                      Colors.green[600]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}