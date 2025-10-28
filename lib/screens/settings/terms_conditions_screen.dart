import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Términos y condiciones",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Términos y condiciones de uso",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // Contenedor de texto de términos
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                "Bienvenido(a) a Agrosig la Aplicación, propiedad de SAI.\n"
                    "Al descargar, acceder o utilizar esta Aplicación, usted acepta quedar sujeto a "
                    "los presentes Términos y Condiciones de Uso. Si no está de acuerdo, le "
                    "recomendamos no utilizar la Aplicación.\n\n"
                    "1. Uso de la Aplicación\n"
                    "El usuario se compromete a utilizar la Aplicación únicamente para fines "
                    "legales y conforme a la normativa aplicable.\n\n"
                    "2. Registro y Cuenta de Usuario\n"
                    "El usuario es responsable de mantener la confidencialidad de sus credenciales de acceso.",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
              ),
            ),

            const SizedBox(height: 20),

            // Checkbox con texto
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Términos y condiciones",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Checkbox(
                  value: _isChecked,
                  activeColor: const Color(0xFF6D927F),
                  shape: const CircleBorder(),
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Botón "Aceptar"
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D927F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isChecked
                      ? () {
                    // Acción al aceptar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Términos aceptados.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                      : null,
                  child: const Text(
                    "Aceptar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
