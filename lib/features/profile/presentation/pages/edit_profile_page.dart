import 'package:auto_route/auto_route.dart';
import 'package:devhub/core/dependency_injection.dart';
import 'package:devhub/features/profile/presentation/providers/profile_notifier.dart';
import 'package:devhub/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class EditProfilePage extends StatefulWidget {
  final ProfileNotifier notifier;

  const EditProfilePage({super.key, required this.notifier});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _roleController;
  late TextEditingController _locationController;
  late TextEditingController _githubUsernameController;

  late final ProfileNotifier notifier;

  @override
  void initState() {
    super.initState();
    notifier = widget.notifier;

    final profile = notifier.profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _roleController = TextEditingController(text: profile?.role ?? '');
    _locationController = TextEditingController(text: profile?.location ?? '');
    _githubUsernameController = TextEditingController(
      text: profile?.githubUsername ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    _githubUsernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          // Consumer<ProfileNotifier>(
          //   builder: (context, notifier, child) {
          //     return
          TextButton(
            onPressed: notifier.isUpdating ? null : _saveProfile,
            child:
                notifier.isUpdating
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save'),
          ),
          // },
          // ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar Section
            Center(
              child: //Consumer<ProfileNotifier>(
              // builder: (context, notifier, child) {
              //    return
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        notifier.avatarUrl != null
                            ? NetworkImage(notifier.avatarUrl!)
                            : null,
                    child:
                        notifier.avatarUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20),
                        color: Colors.white,
                        onPressed:
                            notifier.isUpdating
                                ? null
                                // : () => notifier.pickAndUploadAvatar(),
                                : () => {},
                      ),
                    ),
                  ),
                ],
              ), //;
              // },
              // ),
            ),
            const SizedBox(height: 32),

            // Name Field
            CustomTextField(
              controller: _nameController,
              labelText: 'Name',
              prefixIcon: Icons.person_outline,
              // validator: ValidationRules.required,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Role Field
            CustomTextField(
              controller: _roleController,
              labelText: 'Role',
              prefixIcon: Icons.work_outline,
              hintText: 'e.g., Senior Flutter Developer',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Bio Field
            CustomTextField(
              controller: _bioController,
              labelText: 'Bio',
              prefixIcon: Icons.info_outline,
              hintText: 'Tell us about yourself...',
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Location Field
            CustomTextField(
              controller: _locationController,
              labelText: 'Location',
              prefixIcon: Icons.location_on_outlined,
              hintText: 'e.g., San Francisco, CA',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // GitHub Username Field
            CustomTextField(
              controller: _githubUsernameController,
              labelText: 'GitHub Username',
              prefixIcon: Icons.code,
              hintText: 'your-github-username',
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
            if (notifier.isUpdating)
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),

            // Error Message
            // Consumer<ProfileNotifier>(
            //   builder: (context, notifier, child) {
            if (notifier.errorMessage != null) //{
              // return
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notifier.errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            // },

            // return
            const SizedBox.shrink(),
            // },
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {

      await notifier.updateProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        role: _roleController.text.trim(),
        location: _locationController.text.trim(),
        githubUsername: _githubUsernameController.text.trim(),
      );

      if (notifier.errorMessage == null && mounted) {
        context.router.pop();
      }
    }
  }
}
