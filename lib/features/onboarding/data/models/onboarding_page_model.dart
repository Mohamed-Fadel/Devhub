import 'package:devhub/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_page_model.freezed.dart';
part 'onboarding_page_model.g.dart';

@Freezed(fromJson: true)
sealed class OnboardingPageModel with _$OnboardingPageModel {
  const factory OnboardingPageModel({
    required String id,
    required String title,
    required String subtitle,
    required String description,
    required String imagePath,
    String? animationPath,
    required int primaryColorValue,
    required int secondaryColorValue,
    @Default([]) List<String> features,
  }) = _OnboardingPageModel;

  factory OnboardingPageModel.fromJson(Map<String, dynamic> json) =>
      _$OnboardingPageModelFromJson(json);

}

extension OnboardingPageModelX on OnboardingPageModel {
  OnboardingPage toEntity() {
    return OnboardingPage(
      id: id,
      title: title,
      subtitle: subtitle,
      description: description,
      imagePath: imagePath,
      animationPath: animationPath,
      primaryColor: Color(primaryColorValue),
      secondaryColor: Color(secondaryColorValue),
      features: features,
    );
  }
}

extension OnboardingPageX on OnboardingPage {
  OnboardingPageModel toModel() {
    return OnboardingPageModel(
      id: id,
      title: title,
      subtitle: subtitle,
      description: description,
      imagePath: imagePath,
      animationPath: animationPath,
      primaryColorValue: primaryColor.value,
      secondaryColorValue: secondaryColor.value,
      features: features,
    );
  }
}