# Sistema de Gestión Agrícola Integral 🌱

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18%2B-green.svg)](https://nodejs.org)
[![Express](https://img.shields.io/badge/Express-4.x-lightgrey.svg)](https://expressjs.com)

Una aplicación móvil integral diseñada para ayudar a pequeños y medianos agricultores en México a gestionar eficientemente sus cultivos y optimizar el uso de recursos mediante tecnología accesible.

## 📋 Tabla de Contenidos

- [Descripción del Proyecto](#descripción-del-proyecto)
- [Arquitectura](#arquitectura)
- [Características Principales](#características-principales)
- [Tecnologías Utilizadas](#tecnologías-utilizadas)
- [Instalación](#instalación)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Capturas de Pantalla](#capturas-de-pantalla)
- [Contribución](#contribución)
- [Licencia](#licencia)

## 📖 Descripción del Proyecto

### Problemática
Los pequeños y medianos agricultores en México enfrentan dificultades para gestionar eficientemente el uso de agua, fertilizantes y pesticidas debido a la falta de herramientas tecnológicas accesibles. Esto lleva a un uso ineficiente de recursos, aumento de costos y menor rendimiento de cultivos.

### Solución
Desarrollamos una aplicación móvil integral que permite:
- Registro manual de insumos agrícolas
- Consulta de clima en tiempo real
- Generación de historial trazable del producto (vía QR)
- Acceso a chatbot asesor en temas agrícolas

## 🏗️ Arquitectura

El sistema sigue una arquitectura **cliente-servidor**:

- **Backend**: Node.js con Express
- **Frontend**: Flutter (aplicación móvil)
- **Base de Datos**: [Especificar tu DB]
- **APIs Externas**: Servicios meteorológicos

## ✨ Características Principales

### 🌾 Gestión de Recursos Agrícolas
- ✅ Registrar cultivos (tipo, variedad, fecha de siembra, lote)
- ✅ Registrar actividades (riego, fertilización, fumigación, poda)
- ✅ Control de cantidades utilizadas (litros de agua, kg de fertilizante)
- 📊 Reportes de Cultivos
- 💰 Control de costos por insumo

### 🌤️ Pronóstico del Clima
- 📍 Obtención de pronóstico por geolocalización
- 📅 Clima actual y pronóstico a 7 días
- 🔔 Notificaciones push para eventos climáticos importantes

### 🤖 Chatbot Agrícola
- 💬 Integración de chatbot personalizado
- 📸 Capacidad de subir fotos para diagnóstico

### 📱 Trazabilidad del Producto
- 🏷️ Creación de lotes de producción
- 🔗 Asociación de actividades registradas
- 🔳 Generación de QR único por lote
- 📋 Historial completo accesible mediante QR

## 🛠️ Tecnologías Utilizadas

### Backend
- **Node.js** - Entorno de ejecución
- **Express** - Framework web
- **PostgreSQL/PostGIS** - Sistema de base de datos y herramienta de datos espaciales
- **JWT** - Autenticación
- **Firebase Messaging** - Envio de notificaciones push

### Frontend
- **Flutter** - Framework de UI
- **Dart** - Lenguaje de programación
- **Provider** - Gestión de estado
- **HTTP** - Cliente para APIs
- **QR Code** - Generación de códigos QR

## 🚀 Instalación

### Prerrequisitos
- Flutter SDK 3.0+
- Node.js 18+
- [Base de datos] instalada y configurada

### Backend
```bash
cd api-agrosig-backend
npm install
cp .env.example .env
# Configurar variables de entorno
```

**Modo desarrollo:**

```bash
npm run dev
```

**Modo producción:**

```bash
npm start
```

### Frontend
```bash
cd agrosig_app
flutter pub get
flutter run
```

## 📁 Estructura del Proyecto

```
agrosig_app/
├── android/                 # Configuración Android
├── assets/                  # Recursos estáticos
├── lib/                     # Código fuente Dart
│   ├── components/          # Componentes reutilizables
│   ├── config/              # Configuración de la app
│   ├── controller/          # Controladores y lógica de negocio
│   ├── data/                # Capa de datos y modelos
│   ├── domain/              # Entidades de dominio
│   ├── screens/             # Pantallas de la aplicación
│   ├── firebase_options.dart
│   └── main.dart           # Punto de entrada
├── test/                   # Pruebas unitarias
└── pubspec.yaml           # Dependencias del proyecto
```
## 📸 Capturas de Pantalla

| Pantalla principal | Pantalla de buscador | Pantalla de Predicciones |
|:---:|:---:|:---:|
| <img src="assets/images/cap1.jpg" alt="Pantalla principal" width="200"/> | <img src="assets/images/cap3.jpg" alt="Pantalla de buscador" width="200"/> | <img src="assets/images/cap2.jpg" alt="Pantalla de Predicciones" width="200"/> |


<table border>
    <tr>
        <th style="text-align:center">Home</th>
        <th style="text-align:center">Story</th>
        <th style="text-align:center">Search</th>
    </tr>
    <tr>
        <td><img src="./screenshots/home.png" alt="" width="200"></td>
        <td><img src="./screenshots/story.png" alt="" width="200"></td>
        <td><img src="./screenshots/search-home.png" alt="" width="200"></td>
    <tr>
</table>

<table border>
    <tr>
        <th style="text-align:center">Search | view Photo</th>
        <th style="text-align:center">Search User</th>
        <th style="text-align:center">Profile another user</th>
    </tr>
    <tr>
        <td><img src="./screenshots/search-view-photo.png" alt="" width="200"></td>
        <td><img src="./screenshots/search-user.png" alt="" width="200"></td>
        <td><img src="./screenshots/account-another-user.png" alt="" width="200"></td>
    <tr>
</table>

<table border>
    <tr>
        <th style="text-align:center">Add New post</th>
        <th style="text-align:center">Add new Post</th>
        <th style="text-align:center">Privacy post</th>
    </tr>
    <tr>
        <td><img src="./screenshots/add-new-post.png" alt="" width="200"></td>
        <td><img src="./screenshots/add-new-post-1.png" alt="" width="200"></td>
        <td><img src="./screenshots/add-new-post-privacy.png" alt="" width="200"></td>
    <tr>
</table>

<table border>
    <tr>
        <th style="text-align:center">Activity</th>
        <th style="text-align:center">Profile</th>
        <th style="text-align:center">Profile - Saved</th>
    </tr>
    <tr>
        <td><img src="./screenshots/activity.png" alt="" width="200"></td>
        <td><img src="./screenshots/my-profile.png" alt="" width="200"></td>
        <td><img src="./screenshots/my-profile-two.png" alt="" width="200"></td>
    <tr>
</table>

<table border>
    <tr>
        <th style="text-align:center">Following</th>
        <th style="text-align:center">Followers</th>
        <th style="text-align:center">Modal Settings</th>
    </tr>
    <tr>
        <td><img src="./screenshots/friends.png" alt="" width="200"></td>
        <td><img src="./screenshots/followers.png" alt="" width="200"></td>
        <td><img src="./screenshots/settings-modal.png" alt="" width="200"></td>
    <tr>
</table>

<table border>
    <tr>
        <th style="text-align:center">Settings</th>
        <th style="text-align:center">Privacy</th>
        <th style="text-align:center">Security</th>
    </tr>
    <tr>
        <td><img src="./screenshots/settings.png" alt="" width="200"></td>
        <td><img src="./screenshots/privacy.png" alt="" width="200"></td>
        <td><img src="./screenshots/security.png" alt="" width="200"></td>
    <tr>
</table>

<table border>
    <tr>
        <th style="text-align:center">Account</th>
        <th style="text-align:center">List Messages</th>
        <th style="text-align:center">Chat</th>
    </tr>
    <tr>
        <td><img src="./screenshots/account.png" alt="" width="200"></td>
        <td><img src="./screenshots/list-messages.png" alt="" width="200"></td>
        <td><img src="./screenshots/chat.png" alt="" width="200"></td>
    <tr>
</table>

