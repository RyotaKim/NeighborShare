import 'package:flutter/material.dart';
import '../providers/profile_provider.dart';

class ProfileStatsWidget extends StatelessWidget {
  final ProfileStats stats;

  const ProfileStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              icon: Icons.inventory_2_outlined,
              label: 'Items Listed',
              value: stats.itemsListed.toString(),
            ),
            VerticalDivider(
              color: Theme.of(context).dividerColor,
              thickness: 1,
            ),
            _StatItem(
              icon: Icons.share_outlined,
              label: 'Times Lent',
              value: stats.timesLent.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
