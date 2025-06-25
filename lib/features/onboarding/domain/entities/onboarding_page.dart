import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_page.freezed.dart';

@freezed
sealed class OnboardingPage with _$OnboardingPage {
  const factory OnboardingPage({
    required String id,
    required String title,
    required String subtitle,
    required String description,
    required String imagePath,
    String? animationPath,
    required Color primaryColor,
    required Color secondaryColor,
    @Default([]) List<String> features,
  }) = _OnboardingPage;
}