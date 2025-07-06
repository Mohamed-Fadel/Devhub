import 'package:devhub/core/routing/app_router.gr.dart';
import 'package:devhub/core/routing/route_paths.dart';
import 'package:devhub/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/dependency_injection.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/social_sign_in_button.dart';

@RoutePage()
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: const SignInView(),
    );
  }
}

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          switch (state) {
            case Authenticated(:final user):
              // Navigate to dashboard or home page
              context.router.replaceAll([const DashboardRoute()]);
            case Error(:final message):
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is Loading,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceLG),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),

                      // Logo and Title
                      Icon(
                        Icons.code,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: AppConstants.spaceMD),

                      Text(
                        'Welcome to DevHub',
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spaceSM),

                      Text(
                        'Sign in to your developer account',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spaceXL),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        validator: ValidationRules.email,
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: AppConstants.spaceMD),

                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        obscureText: _obscurePassword,
                        validator:
                            (value) =>
                                ValidationRules.required(value, 'Password'),
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceSM),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.router.pushPath(RoutePaths.forgotPassword);
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceLG),

                      // Sign In Button
                      CustomButton(
                        text: 'Sign In',
                        onPressed: () => _onSignInPressed(context),
                        isLoading: state is Loading,
                      ),
                      const SizedBox(height: AppConstants.spaceLG),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spaceMD,
                            ),
                            child: Text(
                              'OR',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spaceLG),

                      // Social Sign In Buttons
                      SocialSignInButton(
                        icon: 'assets/icons/social/google.svg',
                        text: 'Continue with Google',
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            const AuthEvent.googleSignInRequested(),
                          );
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceMD),

                      SocialSignInButton(
                        icon: 'assets/icons/social/github.svg',
                        text: 'Continue with GitHub',
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            const AuthEvent.githubSignInRequested(),
                          );
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceXL),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              context.router.push(const SignUpRoute());
                            },
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onSignInPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthEvent.signInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }
}
