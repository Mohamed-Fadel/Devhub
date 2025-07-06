import 'package:devhub/core/constants/app_constants.dart';
import 'package:devhub/core/routing/app_router.gr.dart';
import 'package:devhub/core/services/storage_service.dart';
import 'package:devhub/features/auth/bloc/auth_bloc.dart';
import 'package:devhub/features/auth/presentation/pages/sign_in_page.dart';
import 'package:devhub/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../core/dependency_injection.dart';

@RoutePage()
class MainContainerPage extends StatefulWidget {
  const MainContainerPage({super.key});

  @override
  State<MainContainerPage> createState() => _MainContainerPageState();
}

class _MainContainerPageState extends State<MainContainerPage> {
  late PreferencesReaderService _preferencesReaderService;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _preferencesReaderService = getIt<PreferencesReaderService>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>()..add(const AuthEvent.getCurrentUser()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: _handleAuthStateChange,
        child: Scaffold(
          body: Stack(
            children: [
              // Main content area - AutoRouter handles nested navigation
              _buildMainContent(),

              // Global overlays (loading, dialogs, etc.)
              _buildGlobalOverlays(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isInitializing) {
      return _buildInitializingScreen();
    }

    // AutoRouter outlet for nested pages
    return const AutoRouter();
  }

  Widget _buildInitializingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppConstants.spaceMD),
            Text('Initializing App...'),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalOverlays() {
    return Stack(
      children: [
        // You can add global overlays here
        // Example: Network status banner, loading overlay, etc.

        // Example network status (if you have network bloc)
        /*
        BlocBuilder<NetworkBloc, NetworkState>(
          builder: (context, state) {
            if (state is NetworkDisconnected) {
              return _buildNetworkBanner();
            }
            return const SizedBox();
          },
        ),
        */
      ],
    );
  }

  Future<void> _handleAuthStateChange(
    BuildContext context,
    AuthState state,
  ) async {
    final router = context.router;

    switch (state) {
      case Initial():
      case Loading():
        // Show loading state
        setState(() {
          _isInitializing = true;
        });
        break;
      case Authenticated(:final user):
        // User is authenticated
        setState(() {
          _isInitializing = false;
        });
        await _navigateBasedOnAuthState(true);
        break;

      case Unauthenticated():
        // User is not authenticated
        setState(() {
          _isInitializing = false;
        });
        await _navigateBasedOnAuthState(false);
        break;

      case Error(:final message):
        // Show error dialog but still go to sign in
        await _handleAuthError(message);
        break;
    }
  }


  // Future<void> _handleUnauthenticatedUser() async {
  //   if (await _preferencesReaderService.isFirstTime()) {
  //     await _showOnboarding();
  //   } else {
  //     Returning user - show sign in
      // await _showSignIn();
    // }
  // }

  Future<void> _handleAuthError(String message) async {
    // Show error dialog but still go to sign in
    if (mounted) {
      _showErrorDialog(message);
    }
    await _navigateBasedOnAuthState(false);
  }

  Future<void> _navigateBasedOnAuthState(bool isAuthenticated) async {
    final router = context.router;
    final isFirstTime = await _preferencesReaderService.isFirstTime();

    if (isFirstTime) {
      // First time user - show onboarding
      router.replaceAll([const OnboardingRoute()]);
    } else if (isAuthenticated) {
      // Authenticated user - go to dashboard
      router.replaceAll([const DashboardRoute()]);
    } else {
      // Not authenticated - go to sign in
      router.replaceAll([const SignInRoute()]);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: AppConstants.spaceSM),
            Text('Authentication Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('An error occurred during authentication:'),
            const SizedBox(height: AppConstants.spaceSM),
            Text(
              message,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Retry authentication
              context.read<AuthBloc>().add(
                const AuthEvent.getCurrentUser(),
              );
            },
            child: const Text('Retry'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Global dialog methods - can be called from anywhere in the app
  void showGlobalDialog({
    required String title,
    required String content,
    List<Widget>? actions,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions ??
            [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
      ),
    );
  }

  void showGlobalSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Handle auth state changes from anywhere in the app
  void handleGlobalSignOut() {
    context.read<AuthBloc>().add(const AuthEvent.signedOut());
    // The BlocListener will automatically handle navigation
  }

  // Optional: Network status banner
  Widget _buildNetworkBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.red,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 8,
          left: 16,
          right: 16,
        ),
        child: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'No Internet Connection',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
