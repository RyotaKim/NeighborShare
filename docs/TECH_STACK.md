# Tech Stack - NeighborShare

## Overview
Complete technology stack for the NeighborShare item lending platform.

---

## Frontend Framework

<details>
<summary><b>Flutter 3.10.8+</b></summary>

- **Cross-platform mobile development** (iOS, Android, Web)
- **Single codebase** for all platforms
- **Hot reload** for rapid development
- **Material Design 3** components
- **Native performance** with Dart compilation

### Why Flutter?
- Reduced development time with one codebase
- Beautiful, customizable UI components
- Strong community and package ecosystem
- Excellent performance on mobile devices
- Official Google support

</details>

---

## Backend & Database

<details>
<summary><b>Supabase (PostgreSQL)</b></summary>

### Core Features
- **PostgreSQL database** with real-time subscriptions
- **Built-in authentication** with JWT tokens
- **Row Level Security (RLS)** for data protection
- **Storage** for image uploads
- **Edge Functions** for serverless logic
- **Realtime websocket connections**

### Why Supabase?
- Open-source Firebase alternative
- Direct PostgreSQL access (no ORM lock-in)
- Automatic REST and GraphQL APIs
- Built-in authentication with multiple providers
- Real-time subscriptions out of the box
- Free tier for development and small projects

### Supabase Services Used
- **Database**: PostgreSQL 15+ with real-time
- **Authentication**: JWT-based auth with email/password
- **Storage**: S3-compatible object storage
- **Realtime**: WebSocket-based live updates

</details>

---

## State Management

<details>
<summary><b>Riverpod 2.4.9+</b></summary>

### Features
- **Compile-safe provider system**
- **Improved testability** over Provider
- **Better performance** with granular rebuilds
- **Built-in caching** and async support
- **No BuildContext required** for providers

### Why Riverpod?
- Type-safe and compile-time safe
- Easier to test than other state management solutions
- No boilerplate compared to BLoC
- Excellent async/future handling
- Auto-disposal of unused providers
- Better than Provider for complex apps

### Provider Types Used
- `StateNotifierProvider` - For complex state logic
- `FutureProvider` - For async data fetching
- `StreamProvider` - For real-time subscriptions
- `Provider` - For dependency injection

</details>

---

## Navigation

<details>
<summary><b>GoRouter 13.2.0+</b></summary>

### Features
- **Declarative routing** with type-safe parameters
- **Deep linking support** for web and mobile
- **URL-based navigation** for web platform
- **Protected routes** for authentication
- **Nested navigation** for complex flows

### Why GoRouter?
- Official Flutter team recommendation
- Better web support than Navigator 2.0
- Type-safe route parameters
- Simplified deep linking
- Redirect functionality for auth guards
- Better than auto_route for most use cases

### Route Structure
```dart
/                      # Splash/Welcome
/login                 # Login screen
/register              # Registration
/home                  # Main feed (protected)
/item/:id              # Item details (protected)
/add-item              # Add new item (protected)
/chat/:conversationId  # Chat screen (protected)
/profile               # User profile (protected)
```

</details>

---

## Camera & Media

<details>
<summary><b>Image Capture & Processing</b></summary>

### Packages
- **camera: ^0.10.5+9**
  - Native camera access
  - Custom camera UI
  - Video recording support (future)
  
- **image_picker: ^1.0.7**
  - Gallery and camera image selection
  - Platform-specific implementations
  - Cropping support
  
- **flutter_image_compress: ^2.1.0**
  - Image optimization before upload
  - Reduce file size by 70-90%
  - Maintain visual quality
  
- **cached_network_image: ^3.3.1**
  - Efficient image caching
  - Placeholder and error widgets
  - Progressive loading

### Image Pipeline
1. Capture/Select image
2. Compress to < 2MB
3. Generate thumbnail (300x300)
4. Upload to Supabase Storage
5. Save URLs to database
6. Display with caching

</details>

---

## UI Components

<details>
<summary><b>Interface Libraries</b></summary>

### Pre-built Components
- **flutter_chat_ui: ^1.6.12**
  - Pre-built chat interface
  - Message bubbles with avatars
  - Input field with send button
  - Customizable themes
  
- **Material Design 3**
  - Modern UI components
  - Adaptive widgets
  - Color schemes
  - Typography system

### Custom Widget Library
- `ItemCard` - Grid/list item display
- `CategoryFilter` - Chip-based category selector
- `AvailabilityToggle` - Status switch widget
- `CustomBottomNavBar` - Navigation bar
- `LoadingIndicator` - Consistent loading states
- `EmptyState` - No data placeholders
- `ErrorWidget` - Error display with retry

</details>

---

## Utilities

<details>
<summary><b>Helper Packages</b></summary>

### Date & Time
- **intl: ^0.19.0**
  - Internationalization support
  - Date formatting (e.g., "2 hours ago")
  - Number formatting
  - Multi-language support (future)

### Identifiers
- **uuid: ^4.3.3**
  - Generate unique identifiers
  - Used for file names in storage
  - Conversation IDs (if needed client-side)

### Environment Configuration
- **flutter_dotenv: ^5.1.0**
  - Environment variable management
  - Secure API key storage
  - Different configs for dev/prod
  - Never commit secrets to git

### Example .env file
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

</details>

---

## HTTP & Network

<details>
<summary><b>API Communication</b></summary>

### Built-in with Supabase
- **supabase_flutter: ^2.3.0**
  - Includes HTTP client
  - Automatic JWT token injection
  - Request/response serialization
  - WebSocket for real-time

### No additional HTTP package needed
Supabase SDK handles all:
- REST API calls
- Authentication headers
- Token refresh
- Error handling
- Retry logic

</details>

---

## Development Tools

<details>
<summary><b>Code Quality & Testing</b></summary>

### Linting
- **flutter_lints: ^6.0.0**
  - Official Flutter linting rules
  - Enforces best practices
  - Catches common mistakes

### Testing (Dev Dependencies)
- **flutter_test** (SDK)
  - Unit tests
  - Widget tests
  - Integration tests
  
- **mockito: ^5.4.4**
  - Mock dependencies for testing
  - Test isolation
  
- **build_runner: ^2.4.8**
  - Code generation
  - Required for Riverpod code generation (if used)

</details>

---

## Platform-Specific

<details>
<summary><b>Native Integrations</b></summary>

### Android
- **Minimum SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: 34 (Android 14)
- **Permissions Required**:
  - Camera
  - Storage (Read/Write)
  - Internet

### iOS
- **Minimum Version**: iOS 13.0
- **Permissions Required** (Info.plist):
  - `NSCameraUsageDescription`
  - `NSPhotoLibraryUsageDescription`
  - `NSPhotoLibraryAddUsageDescription`

### Web (Future)
- Progressive Web App (PWA) support
- Camera API via browser
- Service Worker for offline

</details>

---

## Complete pubspec.yaml Dependencies

```yaml
name: flutter_application_1
description: NeighborShare - Community item lending platform
version: 1.0.0+1

environment:
  sdk: ^3.10.8

dependencies:
  flutter:
    sdk: flutter
  
  # UI Components
  cupertino_icons: ^1.0.8
  flutter_chat_ui: ^1.6.12
  cached_network_image: ^3.3.1
  
  # Backend & Database
  supabase_flutter: ^2.3.0
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # Navigation
  go_router: ^13.2.0
  
  # Camera & Images
  camera: ^0.10.5+9
  image_picker: ^1.0.7
  flutter_image_compress: ^2.1.0
  
  # Utilities
  intl: ^0.19.0
  uuid: ^4.3.3
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mockito: ^5.4.4
  build_runner: ^2.4.8

flutter:
  uses-material-design: true
  assets:
    - .env
```

---

## Architecture Pattern

<details>
<summary><b>Clean Architecture with Feature-First</b></summary>

### Layer Structure
```
Presentation Layer (UI)
    ↓
Domain Layer (Business Logic)
    ↓
Data Layer (Repository)
    ↓
Supabase (External Service)
```

### Benefits
- **Separation of concerns**
- **Testable code**
- **Maintainable and scalable**
- **Easy to add new features**
- **Independent of frameworks**

</details>

---

## Version Control & CI/CD

<details>
<summary><b>Development Workflow</b></summary>

### Git
- GitHub/GitLab for repository
- Feature branch workflow
- Pull request reviews

### CI/CD (Future)
- **GitHub Actions** or **Codemagic**
- Automated testing on PR
- Automated builds for Android/iOS
- Deploy to TestFlight/Play Console

</details>

---

**Last Updated:** February 5, 2026
