import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileModel profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: profile.hasAvatar 
                ? NetworkImage(profile.avatarUrl!) 
                : null,
            child: profile.hasAvatar
                ? null
                : Text(
                    profile.username[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          // Display Name
          Text(
            profile.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Username
          Text(
            '@${profile.username}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 12),

          // Neighborhood Badge
          if (profile.hasNeighborhood)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profile.neighborhood!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Bio
          if (profile.hasBio)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                profile.bio!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const SizedBox(height: 8),

          // Member Since
          Text(
            'Member since ${DateFormat.yMMM().format(profile.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
