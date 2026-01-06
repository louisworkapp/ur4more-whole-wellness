# UR4MORE Wellness

A holistic wellness application that delivers evidence-based physical, mental, and spiritual health tools with optional faith integration. Built with Flutter for cross-platform mobile and web deployment.

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Python 3.8+ (for gateway services)
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🚀 Quick Start

### Live Demo

🌐 **[View Live Demo](https://louisworkapp.github.io/ur4more-whole-wellness/)** - Explore the Flutter web app UI/UX

> **Note:** The live demo runs in "Demo Mode" without backend connectivity. For full functionality, run locally with the gateway server.

### Local Development

For detailed development setup instructions, see [docs/DEV_RUN.md](docs/DEV_RUN.md).

**Quick start:**
1. Start the Gateway API server (see `gateway/README.md`)
2. Run the Flutter app: `.\run_flutter.ps1` (Windows) or `flutter run` (other platforms)

**Flutter App Location:** The Flutter application is located in the [`ur4more_wellness/`](ur4more_wellness/) directory.

## 🔧 Troubleshooting

### Cursor Windows Connection Fix

If you're experiencing connection issues in Cursor on Windows (e.g., "Connection failed... check internet/VPN" errors), see [docs/CURSOR_CONNECTION_FIX.md](docs/CURSOR_CONNECTION_FIX.md) for a solution related to IPv6 DNS resolution issues.

## 🛠️ Installation

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Install Gateway dependencies:
```bash
cd gateway
pip install -r requirements.txt
```

3. Set up environment:
   - Copy `gateway/.env.example` to `gateway/.env` and configure
   - See [docs/DEV_RUN.md](docs/DEV_RUN.md) for detailed setup

4. Run the application:
   - Start gateway: `cd gateway && python -m uvicorn app.main:app --host 127.0.0.1 --port 8080 --reload`
   - Run Flutter: `.\run_flutter.ps1` (Windows) or see [docs/DEV_RUN.md](docs/DEV_RUN.md) for other platforms

## 📁 Project Structure

```
ur4more_wellness/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/           # Core utilities, services, and truth integration
│   ├── features/       # Feature modules (mind, body, spirit, planner, etc.)
│   ├── presentation/   # UI screens and widgets
│   ├── routes/         # Application routing
│   ├── services/       # Backend service integrations
│   ├── theme/          # Theme configuration
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # Application entry point
├── assets/             # Static assets (images, quotes, courses, scriptures)
│   ├── core/           # Creed and truth anchors
│   ├── courses/        # Discipleship and course content
│   ├── mind/           # Mind Coach exercises and content
│   └── quotes/         # Quote library
├── gateway/            # Python FastAPI gateway service
├── gateway_flask/      # Flask alternative gateway service
├── docs/               # Documentation
├── tools/              # Development and content tools
└── pubspec.yaml        # Project dependencies and configuration
```

## 🏗️ Architecture

UR4MORE Wellness consists of:

- **Flutter App**: Cross-platform mobile and web application
- **Gateway API**: Python-based content gateway (FastAPI or Flask)
- **Content Assets**: JSON-based content files (quotes, scriptures, courses)

See [docs/app_core.md](docs/app_core.md) for core architecture and [docs/DEV_RUN.md](docs/DEV_RUN.md) for development setup.

## Exercise Upgrader

Generate L2/L3 variants from L1 exercises:

```bash
dart run tools/exercise_upgrade.dart --core assets/mind/exercises_core.json --faith assets/mind/exercises_faith.json --write
```

Dry run:
```bash
dart run tools/exercise_upgrade.dart --core assets/mind/exercises_core.json --faith assets/mind/exercises_faith.json --dry-run
```

## Exercise Upgrader

Generate L2/L3 variants from L1 exercises:

```bash
dart run tools/exercise_upgrade.dart --core assets/mind/exercises_core.json --faith assets/mind/exercises_faith.json --write
```

Dry run:
```bash
dart run tools/exercise_upgrade.dart --core assets/mind/exercises_core.json --faith assets/mind/exercises_faith.json --dry-run
```

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```
## 📦 Deployment

### Web (GitHub Pages)

The Flutter web app is automatically deployed to GitHub Pages on every push to `main`. See [docs/DEV_RUN.md](docs/DEV_RUN.md#deploy-to-github-pages) for details.

**Live URL:** `https://louisworkapp.github.io/ur4more-whole-wellness/`

### Mobile

Build the application for production:

```bash
# For Android
cd ur4more_wellness
flutter build apk --release

# For iOS
cd ur4more_wellness
flutter build ios --release
```

## 📚 Documentation

- [Development Setup](docs/DEV_RUN.md) - How to run the app in development
- [App Core Architecture](docs/app_core.md) - Two Powers & Truth Axis framework
- [Security Guidelines](docs/SECURITY.md) - Security practices and secret management
- [Content Governance](docs/governance/content_governance.md) - Content review processes
- [Mind Coach Specification](docs/mind/mind_coach_spec.md) - Mind Coach feature details
- [Gateway API](gateway/README.md) - Gateway service documentation
- [Product Vision](UR4MORE_PRODUCT_VISION.md) - Product vision and strategy

## 🔒 Security

**Important:** Never commit secrets or tokens to the repository. See [docs/SECURITY.md](docs/SECURITY.md) for:
- Secret detection tools (Gitleaks, Trufflehog)
- Pre-commit hooks setup
- Development token configuration
- Git history cleanup procedures

**Secrets Safety:** The app uses `--dart-define` for configuration. No hardcoded tokens or API keys are committed. All sensitive values are passed at build time or stored securely.

## 🙏 Acknowledgments
- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Gateway built with [FastAPI](https://fastapi.tiangolo.com) and [Flask](https://flask.palletsprojects.com)
- Styled with Material Design
