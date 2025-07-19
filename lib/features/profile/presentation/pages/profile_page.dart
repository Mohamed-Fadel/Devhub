import 'package:auto_route/auto_route.dart';
import 'package:devhub/core/dependency_injection.dart';
import 'package:devhub/core/routing/app_router.gr.dart';
import 'package:devhub/core/services/image_picker.dart';
import 'package:devhub/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:devhub/features/profile/presentation/providers/profile_notifier.dart';
import 'package:devhub/features/profile/presentation/widgets/achievements_section.dart';
import 'package:devhub/features/profile/presentation/widgets/github_stats_section.dart';
import 'package:devhub/features/profile/presentation/widgets/profile_header.dart';
import 'package:devhub/features/profile/presentation/widgets/skills_section.dart';
import 'package:devhub/shared/widgets/error_view.dart';
import 'package:devhub/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // @override
  //   State<ProfilePage> createState() => _ProfilePageState();
  // }
  //
  // class _ProfilePageState extends State<ProfilePage> {
  //   @override
  //   void initState() {
  //     super.initState();
  //     // Load profile when page initializes
  //     // WidgetsBinding.instance.addPostFrameCallback((_) {
  //     //   final notifier = context.read<ProfileNotifier>();
  //     //   if (!notifier.hasProfile) {
  //     //     notifier.loadProfile('current_user_id'); // In real app, get from auth
  //     //   }
  //     // });
  //   }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => getIt<ProfileNotifier>()..loadProfile('user_001'),
      child: Scaffold(
        body: Consumer<ProfileNotifier>(
          builder: (context, notifier, child) {
            switch (notifier.status) {
              case ProfileStatus.initial:
              case ProfileStatus.loading:
                return const LoadingView(message: 'Loading profile...');

              case ProfileStatus.error:
                return ErrorView(
                  message: notifier.errorMessage ?? 'Failed to load profile',
                  onRetry: () => notifier.loadProfile('current_user_id'),
                );

              case ProfileStatus.loaded:
                return _buildProfileContent(context, notifier);
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileNotifier notifier) {
    final profile = notifier.profile;
    if (profile == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: () => notifier.loadProfile(profile.id),
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              'Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _navigateToEditProfile(context),
              ),
            ],
          ),

          // Profile Header
          SliverToBoxAdapter(
            child: ProfileHeader(
              profile: profile,
              onAvatarTap:
                  // notifier.isUpdating
                  //     ? null
                  //     :
                () => _pickAndUploadAvatar(context),
            ),
          ),

          // Skills Section
          SliverToBoxAdapter(
            child: SkillsSection(
              skills: profile.skills,
              onAddSkill: (skill) => notifier.addSkill(skill),
              onRemoveSkill: (skillId) => notifier.removeSkill(skillId),
              onUpdateLevel:
                  (skillId, level) => notifier.updateSkillLevel(skillId, level),
              isEditable: true,
            ),
          ),

          // GitHub Stats Section
          if (profile.githubUsername != null)
            SliverToBoxAdapter(
              child: GithubStatsSection(
                stats: profile.githubStats,
                username: profile.githubUsername!,
                isLoading: notifier.isFetchingGithubStats,
                onRefresh: () => notifier.refreshGithubStats(),
              ),
            ),

          // Achievements Section
          SliverToBoxAdapter(
            child: AchievementsSection(achievements: profile.achievements),
          ),

          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final notifier = context.read<ProfileNotifier>();
    final picker = getIt<ImagePickerService>();

    final pickedFilePath = await picker.pickImageFromGallery();
    await notifier.pickAndUploadAvatar(pickedFilePath);
  }

  void _navigateToEditProfile(BuildContext context) {
    final notifier = context.read<ProfileNotifier>();

    context.router.push(
      EditProfileRoute(notifier: notifier),
    );
  }
}
