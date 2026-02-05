import 'package:intl/intl.dart';

/// Date and time formatting utilities
/// Provides user-friendly date/time formatting functions
class DateTimeUtils {
  /// Format a DateTime as relative time
  /// Examples: "Just now", "5 minutes ago", "Yesterday", "3 days ago"
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    // Future dates
    if (difference.isNegative) {
      return 'Just now';
    }
    
    // Less than a minute
    if (difference.inSeconds < 60) {
      return 'Just now';
    }
    
    // Less than an hour
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '${minutes}m ago';
    }
    
    // Less than a day
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h ago';
    }
    
    // Yesterday
    if (difference.inDays == 1) {
      return 'Yesterday';
    }
    
    // Less than a week
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '${days}d ago';
    }
    
    // Less than a month
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    }
    
    // Less than a year
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
    
    // More than a year
    final years = (difference.inDays / 365).floor();
    return years == 1 ? '1 year ago' : '$years years ago';
  }
  
  /// Format a DateTime as a user-friendly date
  /// Examples: "Today", "Yesterday", "Feb 5, 2026", "Dec 25, 2025"
  static String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    // Check if it's today
    if (dateOnly == today) {
      return 'Today';
    }
    
    // Check if it's yesterday
    if (dateOnly == yesterday) {
      return 'Yesterday';
    }
    
    // Check if it's this year
    if (dateTime.year == now.year) {
      return DateFormat('MMM d').format(dateTime); // "Feb 5"
    }
    
    // Different year
    return DateFormat('MMM d, yyyy').format(dateTime); // "Feb 5, 2026"
  }
  
  /// Format a DateTime as time only
  /// Examples: "3:45 PM", "10:30 AM"
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
  
  /// Format a DateTime with both date and time
  /// Examples: "Today 3:45 PM", "Yesterday 10:30 AM", "Feb 5 3:45 PM"
  static String formatDateTime(DateTime dateTime) {
    final date = formatDate(dateTime);
    final time = formatTime(dateTime);
    return '$date $time';
  }
  
  /// Format a DateTime for message timestamps
  /// Shows relative time for recent messages, full date for older ones
  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    // Less than 24 hours - show relative time
    if (difference.inHours < 24) {
      return formatRelativeTime(dateTime);
    }
    
    // Less than a week - show day and time
    if (difference.inDays < 7) {
      final day = DateFormat('EEEE').format(dateTime); // "Monday"
      final time = formatTime(dateTime);
      return '$day $time';
    }
    
    // Older - show full date and time
    return formatDateTime(dateTime);
  }
  
  /// Format a DateTime for conversation list
  /// Shows time if today, date if recent, full date if old
  static String formatConversationTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(dateOnly);
    
    // Today - show time
    if (difference.inDays == 0) {
      return formatTime(dateTime);
    }
    
    // Yesterday
    if (difference.inDays == 1) {
      return 'Yesterday';
    }
    
    // This week - show day name
    if (difference.inDays < 7) {
      return DateFormat('EEEE').format(dateTime); // "Monday"
    }
    
    // This year - show date without year
    if (dateTime.year == now.year) {
      return DateFormat('MMM d').format(dateTime); // "Feb 5"
    }
    
    // Different year - show full date
    return DateFormat('MMM d, yyyy').format(dateTime); // "Feb 5, 2026"
  }
  
  /// Check if a DateTime is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }
  
  /// Check if a DateTime is yesterday
  static bool isYesterday(DateTime dateTime) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }
  
  /// Format duration (e.g., for how long ago something was posted)
  /// Examples: "2 hours", "5 days", "3 weeks"
  static String formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minute${duration.inMinutes != 1 ? 's' : ''}';
    }
    
    if (duration.inHours < 24) {
      return '${duration.inHours} hour${duration.inHours != 1 ? 's' : ''}';
    }
    
    if (duration.inDays < 7) {
      return '${duration.inDays} day${duration.inDays != 1 ? 's' : ''}';
    }
    
    if (duration.inDays < 30) {
      final weeks = (duration.inDays / 7).floor();
      return '$weeks week${weeks != 1 ? 's' : ''}';
    }
    
    if (duration.inDays < 365) {
      final months = (duration.inDays / 30).floor();
      return '$months month${months != 1 ? 's' : ''}';
    }
    
    final years = (duration.inDays / 365).floor();
    return '$years year${years != 1 ? 's' : ''}';
  }
}
