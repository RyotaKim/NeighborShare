# Project Structure - NeighborShare

## Overview
Complete folder architecture following Clean Architecture principles with feature-first organization.

---

## Directory Structure

```
flutter_application_1/
│
├── lib/
│   ├── main.dart                           # App entry point
│   │
│   ├── app/
│   │   ├── app.dart                        # MaterialApp configuration
│   │   └── router.dart                     # GoRouter setup
│   │
│   ├── core/
│   │   ├── constants/
│   │   ├── services/
│   │   ├── utils/
│   │   └── errors/
│   │
│   ├── features/
│   │   ├── auth/
│   │   ├── items/
│   │   ├── chat/
│   │   └── profile/
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   └── theme/
│   │
│   └── config/
│       └── env.dart
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── TECH_STACK.md
│   ├── DATABASE_SCHEMA.md
│   └── FEATURES.md
│
├── .env
├── .env.example
├── .gitignore
├── pubspec.yaml
├── README.md
└── analysis_options.yaml
```

---

## Core Directory

<details>
<summary><b>core/constants/</b></summary>

### app_constants.dart
```dart
class AppConstants {
  // App Info
  static const String appName = 'NeighborShare';
  static const String appVersion = '1.0.0';
  
  // Limits
  static const int maxTitleLength = 60;
  static const int maxDescriptionLength = 500;
  static const int maxBioLength = 500;
  static const int maxUsernameLength = 20;
  static const int minUsernameLength = 3;
  
  // Image
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxAvatarSizeBytes = 2 * 1024 * 1024; // 2MB
  static const int thumbnailSize = 300;
  
  // Pagination
  static const int itemsPerPage = 20;
  static const int messagesPerPage = 50;
}
```

### supabase_constants.dart
```dart
class SupabaseConstants {
  // Tables
  static const String profilesTable = 'profiles';
  static const String itemsTable = 'items';
  static const String conversationsTable = 'conversations';
  static const String messagesTable = 'messages';
  
  // Storage Buckets
  static const String itemImagesBucket = 'item-images';
  static const String avatarsBucket = 'avatars';
  
  // Views
  static const String itemsWithOwnerView = 'items_with_owner';
}
```

### category_constants.dart
```dart
enum ItemCategory {
  tools('Tools', '🔧'),
  kitchen('Kitchen', '🍳'),
  outdoor('Outdoor', '🏕️'),
  games('Games', '🎮');
  
  const ItemCategory(this.label, this.icon);
  final String label;
  final String icon;
}

enum ItemStatus {
  available('Available'),
  onLoan('On Loan');
  
  const ItemStatus(this.label);
  final String label;
}
```

</details>

<details>
<summary><b>core/services/</b></summary>

### supabase_service.dart
```dart
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }
}
```

### auth_service.dart
```dart
class AuthService {
  final SupabaseClient _supabase;
  
  // Sign up with email/password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  });
  
  // Sign in
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });
  
  // Sign out
  Future<void> signOut();
  
  // Get current user
  User? get currentUser;
  
  // Auth state stream
  Stream<AuthState> get authStateChanges;
  
  // Reset password
  Future<void> resetPassword(String email);
}
```

### storage_service.dart
```dart
class StorageService {
  final SupabaseClient _supabase;
  
  // Upload item image
  Future<String> uploadItemImage({
    required String userId,
    required String itemId,
    required File imageFile,
  });
  
  // Upload avatar
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  });
  
  // Delete image
  Future<void> deleteImage({
    required String bucket,
    required String path,
  });
  
  // Get public URL
  String getPublicUrl({
    required String bucket,
    required String path,
  });
}
```

### realtime_service.dart
```dart
class RealtimeService {
  final SupabaseClient _supabase;
  
  // Subscribe to items
  Stream<List<Item>> subscribeToItems({
    ItemStatus? status,
    ItemCategory? category,
  });
  
  // Subscribe to messages
  Stream<List<Message>> subscribeToMessages(String conversationId);
  
  // Subscribe to conversations
  Stream<List<Conversation>> subscribeToConversations(String userId);
}
```

</details>

<details>
<summary><b>core/utils/</b></summary>

### image_utils.dart
```dart
class ImageUtils {
  // Compress image
  static Future<File> compressImage(File file);
  
  // Generate thumbnail
  static Future<File> generateThumbnail(File file, int size);
  
  // Validate image
  static bool isValidImage(File file);
  
  // Get file size
  static int getFileSizeInBytes(File file);
}
```

### date_utils.dart
```dart
class DateUtils {
  // Format relative time ("2 hours ago", "Yesterday")
  static String formatRelativeTime(DateTime dateTime);
  
  // Format date ("Feb 5, 2026")
  static String formatDate(DateTime dateTime);
  
  // Format time ("3:45 PM")
  static String formatTime(DateTime dateTime);
}
```

### validators.dart
```dart
class Validators {
  // Email validation
  static String? validateEmail(String? value);
  
  // Password validation
  static String? validatePassword(String? value);
  
  // Username validation
  static String? validateUsername(String? value);
  
  // Title validation
  static String? validateTitle(String? value);
}
```

</details>

<details>
<summary><b>core/errors/</b></summary>

### app_exception.dart
```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, [this.code]);
}

class AuthException extends AppException {
  AuthException(String message, [String? code]) : super(message, code);
}

class StorageException extends AppException {
  StorageException(String message, [String? code]) : super(message, code);
}

class NetworkException extends AppException {
  NetworkException(String message, [String? code]) : super(message, code);
}
```

### error_handler.dart
```dart
class ErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    if (error is AuthException) {
      return _handleAuthError(error);
    } else if (error is StorageException) {
      return _handleStorageError(error);
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
```

</details>

---

## Features Directory

<details>
<summary><b>features/auth/</b></summary>

### Structure
```
features/auth/
├── data/
│   ├── models/
│   │   └── user_model.dart              # JSON serialization
│   └── repositories/
│       └── auth_repository.dart         # API calls
│
├── domain/
│   └── entities/
│       └── user_entity.dart             # Business model
│
└── presentation/
    ├── screens/
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   ├── forgot_password_screen.dart
    │   └── profile_setup_screen.dart
    │
    ├── widgets/
    │   ├── auth_form.dart
    │   ├── password_field.dart
    │   └── username_field.dart
    │
    └── providers/
        └── auth_provider.dart           # Riverpod state
```

### Key Files

**user_model.dart**
```dart
class UserModel {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  
  factory UserModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**auth_repository.dart**
```dart
class AuthRepository {
  Future<UserModel> signUp(SignUpParams params);
  Future<UserModel> signIn(SignInParams params);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}
```

**auth_provider.dart**
```dart
final authStateProvider = StreamProvider<User?>((ref) {
  return supabase.auth.onAuthStateChange.map((event) => event.session?.user);
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  // Fetch current user profile
});
```

</details>

<details>
<summary><b>features/items/</b></summary>

### Structure
```
features/items/
├── data/
│   ├── models/
│   │   └── item_model.dart
│   └── repositories/
│       └── item_repository.dart
│
├── domain/
│   └── entities/
│       └── item_entity.dart
│
└── presentation/
    ├── screens/
    │   ├── item_feed_screen.dart        # Main browse screen
    │   ├── item_detail_screen.dart      # Single item view
    │   ├── add_item_screen.dart         # Snap-to-List
    │   └── my_items_screen.dart         # User's items list
    │
    ├── widgets/
    │   ├── item_card.dart               # Grid/list item widget
    │   ├── category_filter.dart         # Category chips
    │   ├── availability_toggle.dart     # Status switch
    │   ├── item_image_picker.dart       # Camera/gallery picker
    │   └── category_selector.dart       # Category selection UI
    │
    └── providers/
        ├── items_provider.dart          # All items state
        ├── item_detail_provider.dart    # Single item state
        └── my_items_provider.dart       # User's items state
```

### Key Files

**item_model.dart**
```dart
class ItemModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final ItemCategory category;
  final String? imageUrl;
  final String? thumbnailUrl;
  final ItemStatus status;
  final DateTime createdAt;
  
  factory ItemModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**items_provider.dart**
```dart
// Fetch items with filters
final itemsProvider = StreamProvider.family<List<ItemModel>, ItemFilters>((ref, filters) {
  return ref.read(realtimeServiceProvider).subscribeToItems(
    status: filters.status,
    category: filters.category,
  );
});

// Add item
final addItemProvider = StateNotifierProvider<AddItemNotifier, AsyncValue<void>>((ref) {
  return AddItemNotifier(ref.read(itemRepositoryProvider));
});
```

</details>

<details>
<summary><b>features/chat/</b></summary>

### Structure
```
features/chat/
├── data/
│   ├── models/
│   │   ├── message_model.dart
│   │   └── conversation_model.dart
│   └── repositories/
│       └── chat_repository.dart
│
├── domain/
│   └── entities/
│       ├── message_entity.dart
│       └── conversation_entity.dart
│
└── presentation/
    ├── screens/
    │   ├── conversations_screen.dart    # Inbox/list
    │   └── chat_screen.dart             # Single chat
    │
    ├── widgets/
    │   ├── message_bubble.dart
    │   ├── conversation_tile.dart
    │   └── chat_input.dart
    │
    └── providers/
        ├── conversations_provider.dart
        └── messages_provider.dart
```

### Key Files

**message_model.dart**
```dart
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;
  
  factory MessageModel.fromJson(Map<String, dynamic> json);
}
```

**messages_provider.dart**
```dart
final messagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  return ref.read(realtimeServiceProvider).subscribeToMessages(conversationId);
});

final sendMessageProvider = StateNotifierProvider<SendMessageNotifier, AsyncValue<void>>((ref) {
  return SendMessageNotifier(ref.read(chatRepositoryProvider));
});
```

</details>

<details>
<summary><b>features/profile/</b></summary>

### Structure
```
features/profile/
├── data/
│   ├── models/
│   │   └── profile_model.dart
│   └── repositories/
│       └── profile_repository.dart
│
├── domain/
│   └── entities/
│       └── profile_entity.dart
│
└── presentation/
    ├── screens/
    │   ├── profile_screen.dart          # View profile
    │   └── edit_profile_screen.dart     # Edit form
    │
    ├── widgets/
    │   ├── profile_header.dart          # Avatar + name
    │   ├── profile_stats.dart           # Item stats
    │   └── avatar_picker.dart
    │
    └── providers/
        └── profile_provider.dart
```

</details>

---

## Shared Directory

<details>
<summary><b>shared/widgets/</b></summary>

### Common Widgets

**app_bar.dart**
```dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  // ...
}
```

**bottom_nav_bar.dart**
```dart
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  // Tabs: Home, Add, Chat, Profile
}
```

**loading_indicator.dart**
```dart
class LoadingIndicator extends StatelessWidget {
  final String? message;
  // Show circular progress indicator
}
```

**error_widget.dart**
```dart
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  // Show error with retry button
}
```

**empty_state.dart**
```dart
class EmptyState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  // Show empty state with optional action
}
```

**custom_button.dart**
```dart
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  // Styled button with loading state
}
```

</details>

<details>
<summary><b>shared/theme/</b></summary>

### app_theme.dart
```dart
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: AppTextStyles.textTheme,
    );
  }
  
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: AppTextStyles.textTheme,
    );
  }
}
```

### colors.dart
```dart
class AppColors {
  // Primary
  static const Color primary = Color(0xFF6750A4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Secondary
  static const Color secondary = Color(0xFF625B71);
  
  // Status
  static const Color available = Color(0xFF4CAF50);
  static const Color onLoan = Color(0xFFF44336);
  
  // Categories
  static const Color tools = Color(0xFFFF9800);
  static const Color kitchen = Color(0xFF4CAF50);
  static const Color outdoor = Color(0xFF2196F3);
  static const Color games = Color(0xFF9C27B0);
}
```

### text_styles.dart
```dart
class AppTextStyles {
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );
}
```

</details>

---

## Config Directory

<details>
<summary><b>config/env.dart</b></summary>

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }
}
```

### .env.example
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

</details>

---

## App Entry Points

<details>
<summary><b>main.dart</b></summary>

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'config/env.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await EnvConfig.load();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  runApp(
    const ProviderScope(
      child: NeighborShareApp(),
    ),
  );
}
```

</details>

<details>
<summary><b>app/app.dart</b></summary>

```dart
class NeighborShareApp extends ConsumerWidget {
  const NeighborShareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'NeighborShare',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      routerConfig: router,
    );
  }
}
```

</details>

<details>
<summary><b>app/router.dart</b></summary>

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/register';
      
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      if (isLoggedIn && isLoginRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const ItemFeedScreen(),
      ),
      GoRoute(
        path: '/item/:id',
        builder: (context, state) => ItemDetailScreen(
          itemId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/add-item',
        builder: (context, state) => const AddItemScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) => ChatScreen(
          conversationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
```

</details>

---

## Testing Directory

<details>
<summary><b>test/</b></summary>

### Structure
```
test/
├── unit/
│   ├── services/
│   │   ├── auth_service_test.dart
│   │   └── storage_service_test.dart
│   ├── repositories/
│   │   └── item_repository_test.dart
│   └── utils/
│       └── validators_test.dart
│
├── widget/
│   ├── item_card_test.dart
│   ├── category_filter_test.dart
│   └── message_bubble_test.dart
│
└── integration/
    ├── auth_flow_test.dart
    ├── add_item_flow_test.dart
    └── chat_flow_test.dart
```

</details>

---

## Assets Directory

<details>
<summary><b>assets/</b></summary>

### Structure
```
assets/
├── images/
│   ├── logo.png
│   ├── splash.png
│   └── empty_states/
│       ├── no_items.svg
│       └── no_messages.svg
│
├── icons/
│   └── category_icons/
│       ├── tools.svg
│       ├── kitchen.svg
│       ├── outdoor.svg
│       └── games.svg
│
└── fonts/
    └── Inter/
        ├── Inter-Regular.ttf
        ├── Inter-Medium.ttf
        └── Inter-Bold.ttf
```

### pubspec.yaml (assets section)
```yaml
flutter:
  uses-material-design: true
  
  assets:
    - .env
    - assets/images/
    - assets/icons/
    
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter/Inter-Regular.ttf
        - asset: assets/fonts/Inter/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter/Inter-Bold.ttf
          weight: 700
```

</details>

---

**Last Updated:** February 5, 2026
