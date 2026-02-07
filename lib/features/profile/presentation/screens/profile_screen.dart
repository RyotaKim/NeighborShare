import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../items/presentation/providers/my_items_provider.dart';
import '../../../items/presentation/widgets/item_card.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart' show ProfileStatsWidget;

class ProfileScreen extends ConsumerWidget {
  final String? userId; // If null, show current user's profile

  const ProfileScreen({super.key, this.userId});

  bool get isOwnProfile => userId == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If no userId provided, use current user
    final authState = ref.watch(authStateProvider);
    final effectiveUserId = userId ?? authState.value?.session?.user.id;

    if (effectiveUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: Text('Please log in to view profile'),
        ),
      );
    }

    final profileAsync = isOwnProfile
        ? ref.watch(currentProfileProvider)
        : ref.watch(profileByIdProvider(effectiveUserId));

    final statsAsync = ref.watch(profileStatsProvider(effectiveUserId));

    final itemsAsync = ref.watch(userItemsProvider(effectiveUserId));

    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? 'My Profile' : 'Profile'),
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/edit-profile'),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('Profile not found'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentProfileProvider);
              ref.invalidate(profileStatsProvider(effectiveUserId));
              ref.invalidate(userItemsProvider(effectiveUserId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Profile Header
                  ProfileHeader(profile: profile),

                  const SizedBox(height: 24),

                  // Stats Section
                  statsAsync.when(
                    data: (stats) => ProfileStatsWidget(stats: stats),
                    loading: () => const SmallLoadingIndicator(),
                    error: (err, stack) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // My Items Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isOwnProfile ? 'My Items' : '${profile.displayName}\'s Items',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (isOwnProfile)
                          TextButton.icon(
                            onPressed: () => context.push('/my-items'),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('View All'),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Items Grid
                  itemsAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isOwnProfile 
                                    ? 'No items listed yet'
                                    : 'No items available',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (isOwnProfile) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap the + button to add your first item',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return ItemCard(
                              item: items[index],
                              onTap: () => context.push('/item/${items[index].id}'),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: LoadingIndicator(message: 'Loading items...'),
                    ),
                    error: (err, stack) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CompactErrorDisplay(
                        message: 'Failed to load items',
                        onRetry: () => ref.invalidate(userItemsProvider(effectiveUserId)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logout Button (only for own profile)
                  if (isOwnProfile) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context, ref),
                        icon: const Icon(Icons.logout),
                        label: const Text('Log Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading profile...'),
        error: (err, stack) => ErrorDisplay(
          message: 'Failed to load profile',
          onRetry: () {
            if (isOwnProfile) {
              ref.invalidate(currentProfileProvider);
            } else {
              ref.invalidate(profileByIdProvider(effectiveUserId));
            }
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
