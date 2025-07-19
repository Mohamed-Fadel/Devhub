import 'package:flutter/material.dart';
import '../../domain/entities/profile.dart';

class ProfileHeader extends StatelessWidget {
  final Profile profile;
  final VoidCallback? onAvatarTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: profile.avatarUrl != null
                      ? ClipOval(
                    child: Image.network(
                      profile.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  )
                      : const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              if (onAvatarTap != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Role
          if (profile.role != null)
            Text(
              profile.role!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          const SizedBox(height: 8),

          // Location
          if (profile.location != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  profile.location!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),

          // Bio
          if (profile.bio != null) ...[
            const SizedBox(height: 16),
            Text(
              profile.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}