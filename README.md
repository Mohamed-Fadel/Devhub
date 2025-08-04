[![Flutter Version](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.7+-blue.svg)](https://dart.dev/)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green.svg)
![State Management](https://img.shields.io/badge/State%20Management-BLoC%20|%20Riverpod%20|%20Provider-orange.svg)

> **A comprehensive Flutter architecture showcase demonstrating top development practices, multiple state management patterns, and production-ready features.**

This repository demonstrates:

### ✅ **Architecture Excellence**
- Clean Architecture implementation
- Multiple design patterns (Repository, Factory, Observer)
- SOLID principles adherence
- Separation of concerns

### ✅ **State Management Mastery**
- BLoC pattern for complex flows (Authentication, Onboarding)
- Riverpod for modern reactive programming (Dashboard)
- Provider for traditional state management (Profile)

### ✅ **Production-Ready Quality**
- Comprehensive error handling and logging
- Security best practices (secure storage, token management)
- Performance optimization (lazy loading, caching, memory management)
- Accessibility compliance (screen readers, contrast, focus management)

### ✅ **Modern Flutter Practices**
- Material Design 3 implementation
- Responsive design for all platforms
- Dark/light theme support
- Internationalization ready

---

## 🎬 Video Demo

[![Watch the video](https://github.com/user-attachments/assets/25504da3-55c6-4bf8-9d7f-8524317515c6)](https://youtu.be/txMrr1poP4o)

**[▶️ Watch Full Demo Video](https://youtu.be/txMrr1poP4o)** *(1 minute)*

See the app in action: Onboarding flow • Authentication flow • Dashboard features • Profile management • Real-time updates • Responsive design
</div>

---

🎯 Project Overview

**DevHub** is a developer portfolio and social platform built to demonstrate advanced Flutter architecture patterns and best practices. This project serves as a comprehensive showcase of modern Flutter development, featuring multiple state management solutions, clean architecture, and production-ready features.

### 🏆 What Makes This Project Special

- **Modular Feature-Based Structure** - Each feature is self-contained and independently maintainable
- **Multiple Architecture Patterns** - Clean Architecture, MVVM, Repository Pattern
- **Multiple State Management** - BLoC, Riverpod, Provider (comparative implementation)
- **Dependency Injection** - Using GetIt and Injectable for proper dependency management
- **Advanced Routing** - Modular routing system with AutoRoute
- **Production-Ready Features** - Authentication, offline support, performance optimization
- **Real-World Complexity** - Complex UI, data visualization, real-time features

## App Features

### Onboarding Module (BLoC Pattern)
- Interactive onboarding flow with animations
- Page indicators and navigation controls
- Skip functionality for returning users
- Animated backgrounds and smooth transitions
- Completion tracking with local storage
- Seamless navigation to authentication

### Authentication Module (BLoC Pattern)
- Email/Password authentication
- Social login (Google, GitHub) (in-progress)
- Biometric authentication (in-progress)
- Password reset functionality (in-progress)
- JWT token management with auto-refresh (in-progress)

### Dashboard Module (Riverpod Pattern)
- Real-time developer statistics
- Activity feed with infinite scroll
- Performance metrics visualization
- Offline-first architecture with sync

###  Profile Module (Provider Pattern)
- Profile management and editing
- Skills and achievements system
- GitHub integration for stats
- Image upload and caching (in-progress)

## 🏗️ Architecture

### Clean Architecture Implementation

```
lib/
├── app/                          # Application layer
│   └── pages/                    # App-level pages
│
├── core/                         # Core functionality
│   ├── constants/                # App constants
│   ├── data/                     # Core data layer
│   ├── domain/                   # Core domain layer
│   ├── network/                  # Network configuration
│   ├── routing/                  # Routing infrastructure
│   ├── services/                 # Core services (interfaces)
│   ├── theme/                    # App theming
│   └── utils/                    # Utilities
│
├── features/                     # Feature modules
│   ├── onboarding/               # Onboarding feature
│   │   ├── domain/               # Business logic
│   │   │   ├── entities/         # Business objects
│   │   │   ├── repositories/     # Repository interfaces
│   │   │   └── usecases/         # Business rules
│   │   ├── data/                 # Data layer
│   │   │   ├── datasources/      # Remote/Local sources
│   │   │   ├── models/           # Data models
│   │   │   └── repositories/     # Repository implementations
│   │   ├── presentation/         # UI layer
│   │   │   ├── bloc/             # State management
│   │   │   ├── pages/            # Screen widgets
│   │   │   ├── widgets/          # Reusable widgets
│   │   │   └── routing/          # Feature routing
│   │   ├── routing/              # routing configuration
│   │   └── services/             # Feature-specific services implementations
│   │
│   ├── auth/                     # Auth feature (similar structure)
│   ├── dashboard/                # Dashboard feature
│   └── profile/                  # Profile feature
│
├── infrastructure/               # Infrastructure layer
│   ├── network/                  # Network clients and interceptors
│   └── services/                 # Third-party service implementations
│
└── shared/                       # Shared code between features
    ├── domain/                   # Shared domain logic
    └── presentation/             # Shared UI components
```

### 🔄 Data Flow Architecture

```
┌─────────────────┐
│   Presentation  │ (UI + State Management)
│  BLoC/Riverpod  │
└────────┬────────┘
         │ Stream/State
┌────────▼────────┐
│     Domain      │ (Use Cases + Entities)
│  Business Logic │
└────────┬────────┘
         │ Repository Interface
┌────────▼────────┐
│      Data       │ (Repository Implementation)
│  Local/Remote   │
└─────────────────┘
```

### 🧩 Modular Routing System

Each feature module manages its own routes:

```dart
// Feature-level router
class OnboardingRouter implements BaseRouter {
  @override
  String get baseRoute => '/onboarding';
  
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: OnboardingRoute.page, path: baseRoute),
  ];
}

// Centralized route registration
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> routes => [
    ...onboardingRouter.routes,
    ...authRouter.routes,
    ...dashboardRouter.routes,
  ];
}
```

### State Management Comparison

| Feature | BLoC | Riverpod | Provider | Custom |
|---------|------|----------|----------|--------|
| **Authentication** | ✅ Primary | | | |
| **Dashboard** | | ✅ Primary | | |
| **Profile** | | | ✅ Primary | |

### Dependency Injection

Using **GetIt** with **Injectable** for compile-time dependency injection:

```dart
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final AuthRepository _authRepository;
  
  AuthBloc(this._signInUseCase, this._authRepository);
}
```

## Technical Stack

### Core Technologies
- **Flutter 3.16+** - Latest stable version
- **Dart 3.7+** - Null safety, records, patterns
- **Material Design 3** - Modern UI components

### State Management
- **flutter_bloc** ^8.1.3 - BLoC pattern implementation
- **flutter_riverpod** ^2.4.9 - Modern state management
- **provider** ^6.1.1 - Traditional Flutter state management

### Networking & Serialization
- **dio** ^5.4.0 - HTTP client with interceptors
- **retrofit** ^4.0.3 - Type-safe API calls
- **json_annotation** ^4.8.1 - JSON serialization
- **freezed** ^2.4.6 - Immutable data classes

### Local Storage
- **hive** ^2.2.3 - NoSQL local database
- **drift** ^2.14.1 - SQLite with type safety
- **flutter_secure_storage** ^9.0.0 - Secure storage

### UI & Animations
- **lottie** ^2.7.0 - Lottie animations
- **rive** ^0.12.4 - Interactive animations
- **shimmer** ^3.0.0 - Shimmer loading effects
- **fl_chart** ^0.66.0 - Beautiful charts

### Development & Quality
- **very_good_analysis** ^5.1.0 - Strict linting rules
- **injectable** ^2.3.2 - Dependency injection
- **auto_route** ^7.9.2 - Code generation routing

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.16.0 or higher)
- Dart SDK (3.7.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/devhub-flutter.git
cd devhub-flutter
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app**
```bash
flutter run
```

### Environment Setup

Create a `.env` file in the root directory:

```env
API_BASE_URL=https://api.devhub.com
API_KEY=your_api_key_here
GOOGLE_CLIENT_ID=your_google_client_id
GITHUB_CLIENT_ID=your_github_client_id
```

## Testing Strategy

### Testing Pyramid

```
🔺 Integration Tests (E2E user flows)
🔺🔺 Widget Tests (UI components)  
🔺🔺🔺 Unit Tests (Business logic)
```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## Performance Optimization

### Key Optimizations Implemented

1. **Lazy Loading** - Widgets and data loaded on demand
2. **Image Caching** - Efficient network image caching
3. **Memory Management** - Proper disposal of controllers and streams
4. **Database Optimization** - Indexed queries and pagination

## Design System

### Design Principles

- **Consistency** - Unified design language across all screens
- **Accessibility** - WCAG 2.1 AA compliant
- **Spacing System**: 8pt grid system
- **Component Library**: Reusable UI components
- **Responsiveness** - Adaptive design for all screen sizes
- **Performance** - Optimized animations and interactions

### Key Components

```dart
// Custom Design System Implementation
class AppTheme {
  static ThemeData get lightTheme => // Modern Material 3 theme
  static ThemeData get darkTheme => // Dark mode support
}

class AppColors {
  static const primary = Color(0xFF6366F1);    // Indigo
  static const secondary = Color(0xFF10B981);  // Emerald
  static const accent = Color(0xFFF59E0B);     // Amber
}
```

## Code Quality

### Code Generation

Extensive use of code generation for:
- **Freezed** - Immutable data classes
- **Injectable** - Dependency injection
- **Auto Route** - Type-safe routing
- **JSON Serializable** - Model serialization

## 🏆 What This Demonstrates

### For Flutter Expertise

1. **Advanced Architecture** - Multiple proven patterns in production
2. **State Management Mastery** - Comparative implementation of major solutions
3. **Performance Optimization** - Real-world optimization techniques
4. **Code Quality** - Production-ready code standards

## Continuous Improvement

### Planned Enhancements

- [ ] **Testing Suite** - Comprehensive unit and integration tests
- [ ] **Offline-First Architecture** - Complete offline functionality
- [ ] **Micro-Frontend Architecture** - Modular feature development
- [ ] **Advanced Analytics** - Machine learning insights
- [ ] **Accessibility Improvements** - Enhanced screen reader support
- [ ] **Performance Monitoring** - Real-time performance tracking

### Current Status

- ✅ **Authentication System** - Complete with social login
- ✅ **Core Architecture** - Clean Architecture implemented
- ✅ **State Management** - Multiple patterns demonstrated
- ✅ **UI/UX Design** - Modern, responsive design system
- ⏳ **Testing Suite** - Creating comprehensive testing suite In progress
- ⏳ **Real-time Features** - WebSocket integration in progress
- ⏳ **Advanced Analytics** - Charts and visualization in progress

## 
