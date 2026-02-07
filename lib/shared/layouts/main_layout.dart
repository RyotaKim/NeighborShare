import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav_bar.dart';

/// Main layout with bottom navigation
class MainLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: widget.currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.push('/add-item');
              break;
            case 2:
              context.go('/conversations');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        unreadMessageCount: null, // TODO: Implement unread message count
      ),
    );
  }
}

/// Helper to determine which tab is active based on location
int getTabIndex(String location) {
  if (location.startsWith('/conversations') || location.startsWith('/chat')) {
    return 2; // Chat
  } else if (location.startsWith('/profile') || location.startsWith('/edit-profile')) {
    return 3; // Profile
  } else if (location == '/' || location.startsWith('/item')) {
    return 0; // Home
  }
  return 0; // Default to home
}
