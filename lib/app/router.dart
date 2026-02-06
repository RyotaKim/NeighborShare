import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/email_verification_screen.dart';
import '../features/auth/presentation/screens/profile_setup_screen.dart';
import '../features/items/presentation/screens/item_feed_screen.dart';
import '../features/items/presentation/screens/item_detail_screen.dart';
import '../features/items/presentation/screens/add_item_screen.dart';
import '../features/items/presentation/screens/my_items_screen.dart';
import '../features/chat/presentation/screens/conversations_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/data/models/conversation_model.dart';

// Routes constants
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String profileSetup = '/profile-setup';
  static const String home = '/';
  static const String itemDetail = '/item/:id';
  static const String addItem = '/add-item';
  static const String myItems = '/my-items';
  static const String conversations = '/conversations';
  static const String chat = '/chat/:id';
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  // Watch authentication state via authNotifierProvider (works on all platforms)
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isRegistering = state.matchedLocation == AppRoutes.register;
      final isForgotPassword = state.matchedLocation == AppRoutes.forgotPassword;
      final isEmailVerification = state.matchedLocation == AppRoutes.emailVerification;
      final isProfileSetup = state.matchedLocation == AppRoutes.profileSetup;

      // Define auth screens (screens accessible when not authenticated)
      final isAuthScreen = isLoggingIn || isRegistering || isForgotPassword || isEmailVerification;

      // If not authenticated and not on an auth screen, redirect to login
      if (!isAuthenticated && !isAuthScreen) {
        return AppRoutes.login;
      }

      // If authenticated and on an auth screen (except profile setup), redirect to home
      if (isAuthenticated && isAuthScreen && !isProfileSetup) {
        return AppRoutes.home;
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        name: 'email-verification',
        builder: (context, state) {
          final email = state.extra as String?;
          if (email == null) {
            // Redirect to login if no email provided
            return const LoginScreen();
          }
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const ItemFeedScreen(),
      ),
      GoRoute(
        path: '/item/:id',
        name: 'item-detail',
        builder: (context, state) {
          final itemId = state.pathParameters['id']!;
          return ItemDetailScreen(itemId: itemId);
        },
      ),
      GoRoute(
        path: AppRoutes.addItem,
        name: 'add-item',
        builder: (context, state) => const AddItemScreen(),
      ),
      GoRoute(
        path: AppRoutes.myItems,
        name: 'my-items',
        builder: (context, state) => const MyItemsScreen(),
      ),
      GoRoute(
        path: AppRoutes.conversations,
        name: 'conversations',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (context, state) {
          final conversationId = state.pathParameters['id']!;
          final conversation = state.extra as ConversationModel?;
          return ChatScreen(
            conversationId: conversationId,
            conversation: conversation,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.matchedLocation}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
