import 'package:devhub/core/constants/app_constants.dart';
import 'package:devhub/core/utils/validators.dart';
import 'package:devhub/features/profile/domain/entities/profile.dart';
import 'package:devhub/features/profile/presentation/providers/profile_notifier.dart';
import 'package:devhub/shared/widgets/custom_button.dart';
import 'package:devhub/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileForm extends StatefulWidget {
  final Profile profile;
  final bool isEditing;
  final VoidCallback? onCancel;

  const ProfileForm({
    super.key,
    required this.profile,
    this.isEditing = false,
    this.onCancel,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _roleController;
  late TextEditingController _locationController;
  late TextEditingController _githubUsernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _roleController = TextEditingController(text: widget.profile.role ?? '');
    _locationController = TextEditingController(
      text: widget.profile.location ?? '',
    );
    _githubUsernameController = TextEditingController(
      text: widget.profile.githubUsername ?? '',
    );
    _emailController = TextEditingController(text: widget.profile.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    _githubUsernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Field
          CustomTextField(
            controller: _nameController,
            labelText: 'Full Name',
            prefixIcon: Icons.person_outline,
            validator: ValidationRules.name,
            enabled: widget.isEditing,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppConstants.spaceMD),

          // Email Field (usually not editable)
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            prefixIcon: Icons.email_outlined,
            enabled: false,
            // Email typically cannot be changed
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppConstants.spaceMD),

          // Role Field
          CustomTextField(
            controller: _roleController,
            labelText: 'Professional Role',
            prefixIcon: Icons.work_outline,
            hintText: 'e.g., Senior Flutter Developer',
            enabled: widget.isEditing,
            textInputAction: TextInputAction.next,
            validator: (value) => ValidationRules.minLength(value, 2, 'Role'),
          ),
          const SizedBox(height: AppConstants.spaceMD),

          // Bio Field
          CustomTextField(
            controller: _bioController,
            labelText: 'Bio',
            prefixIcon: Icons.info_outline,
            hintText: 'Tell us about yourself...',
            maxLines: 4,
            enabled: widget.isEditing,
            textInputAction: TextInputAction.next,
            validator: (value) => ValidationRules.maxLength(value, 500, 'Bio'),
          ),
          const SizedBox(height: AppConstants.spaceMD),

          // Location Field
          CustomTextField(
            controller: _locationController,
            labelText: 'Location',
            prefixIcon: Icons.location_on_outlined,
            hintText: 'e.g., San Francisco, CA',
            enabled: widget.isEditing,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppConstants.spaceMD),

          // GitHub Username Field
          CustomTextField(
            controller: _githubUsernameController,
            labelText: 'GitHub Username',
            prefixIcon: Icons.code,
            hintText: 'your-github-username',
            enabled: widget.isEditing,
            textInputAction: TextInputAction.done,
            validator: ValidationRules.githubUsername,
            onChanged: widget.isEditing ? _onGithubUsernameChanged : null,
          ),

          if (widget.isEditing) ...[
            const SizedBox(height: AppConstants.spaceXL),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    isOutlined: true,
                    onPressed: widget.onCancel ?? () => _resetForm(),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMD),
                Expanded(
                  child: Consumer<ProfileNotifier>(
                    builder: (context, notifier, _) {
                      return CustomButton(
                        text: 'Save Changes',
                        isLoading: notifier.isUpdating,
                        onPressed: notifier.isUpdating ? null : _saveProfile,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],

          // Character count for bio
          if (widget.isEditing)
            Padding(
              padding: const EdgeInsets.only(top: AppConstants.spaceSM),
              child: Text(
                '${_bioController.text.length}/500 characters',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      _bioController.text.length > 500
                          ? Colors.red
                          : Colors.grey,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  void _onGithubUsernameChanged(String value) {
    // Debounce GitHub stats fetching
    // In a real app, you might want to use a debouncer
    if (value.isNotEmpty && value != widget.profile.githubUsername) {
      // The ProfileNotifier will handle fetching GitHub stats
      // when the profile is updated
    }
  }

  void _resetForm() {
    setState(() {
      _nameController.text = widget.profile.name;
      _bioController.text = widget.profile.bio ?? '';
      _roleController.text = widget.profile.role ?? '';
      _locationController.text = widget.profile.location ?? '';
      _githubUsernameController.text = widget.profile.githubUsername ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final notifier = Provider.of<ProfileNotifier>(context);

      await notifier.updateProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        role: _roleController.text.trim(),
        location: _locationController.text.trim(),
        githubUsername: _githubUsernameController.text.trim(),
      );

      if (mounted && notifier.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

// Compact version for displaying profile info (non-editable)
class ProfileInfoCard extends StatelessWidget {
  final Profile profile;
  final VoidCallback? onEdit;

  const ProfileInfoCard({super.key, required this.profile, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                  ),
              ],
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Name',
              value: profile.name,
            ),
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: profile.email,
            ),
            if (profile.role != null)
              _buildInfoRow(
                icon: Icons.work_outline,
                label: 'Role',
                value: profile.role!,
              ),
            if (profile.location != null)
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: profile.location!,
              ),
            if (profile.githubUsername != null)
              _buildInfoRow(
                icon: Icons.code,
                label: 'GitHub',
                value: '@${profile.githubUsername}',
              ),
            if (profile.bio != null) ...[
              const SizedBox(height: AppConstants.spaceMD),
              Text(
                'Bio',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppConstants.spaceSM),
              Text(profile.bio!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceSM),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: AppConstants.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
