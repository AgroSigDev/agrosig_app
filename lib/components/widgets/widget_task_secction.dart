import 'package:flutter/material.dart';

class TasksToDoSection extends StatelessWidget {
  const TasksToDoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tasks To Do",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "See All",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTaskItem(
          icon: Icons.water_drop_outlined,
          title: "Riego - Maíz Lote 3",
          subtitle: "10:00 AM - Hoy",
          onTap: () {
            print('Navegar a detalles de riego');
          },
        ),
        _buildTaskItem(
          icon: Icons.eco_outlined,
          title: "Fertilización - Trigo Lote 1",
          subtitle: "Pendiente - Esta semana",
          isUrgent: true,
          onTap: () {
            print('Navegar a detalles de fertilización');
          },
        ),
        _buildTaskItem(
          icon: Icons.bug_report_outlined,
          title: "Control de Plagas - Tomate",
          subtitle: "Revisar - Próximos días",
          onTap: () {
            print('Navegar a control de plagas');
          },
        ),
      ],
    );
  }

  Widget _buildTaskItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isUrgent = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUrgent ? Colors.orange[100]! : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isUrgent ? Colors.orange : Colors.green,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isUrgent ? Colors.orange[800] : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}