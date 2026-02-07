import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('should return null for valid email', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
      expect(Validators.validateEmail('user.name+tag@example.co.uk'), isNull);
      expect(Validators.validateEmail('test123@test-domain.com'), isNull);
    });

    test('should return error for empty email', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('should return error for invalid email format', () {
      expect(Validators.validateEmail('notanemail'), isNotNull);
      expect(Validators.validateEmail('missing@domain'), isNotNull);
      expect(Validators.validateEmail('@example.com'), isNotNull);
      expect(Validators.validateEmail('test@'), isNotNull);
      expect(Validators.validateEmail('test @example.com'), isNotNull);
    });
  });

  group('Validators - Password', () {
    test('should return null for valid password', () {
      expect(Validators.validatePassword('password123'), isNull);
      expect(Validators.validatePassword('MySecurePass1'), isNull);
      expect(Validators.validatePassword('abc12345'), isNull);
    });

    test('should return error for empty password', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword(null), isNotNull);
    });

    test('should return error for password shorter than 8 characters', () {
      expect(Validators.validatePassword('pass1'), isNotNull);
      expect(Validators.validatePassword('abc123'), isNotNull);
    });

    test('should return error for password without letters', () {
      expect(Validators.validatePassword('12345678'), isNotNull);
    });

    test('should return error for password without numbers', () {
      expect(Validators.validatePassword('password'), isNotNull);
    });

    test('should accept password up to 72 characters', () {
      final longPassword = 'a' * 60 + '123456789012';
      expect(Validators.validatePassword(longPassword), isNull);
    });
  });

  group('Validators - Username', () {
    test('should return null for valid username', () {
      expect(Validators.validateUsername('john_doe'), isNull);
      expect(Validators.validateUsername('user123'), isNull);
      expect(Validators.validateUsername('test_user_name'), isNull);
      expect(Validators.validateUsername('abc'), isNull); // Minimum 3 chars
    });

    test('should return error for empty username', () {
      expect(Validators.validateUsername(''), isNotNull);
      expect(Validators.validateUsername(null), isNotNull);
    });

    test('should return error for username shorter than 3 characters', () {
      expect(Validators.validateUsername('ab'), isNotNull);
      expect(Validators.validateUsername('x'), isNotNull);
    });

    test('should return error for username with invalid characters', () {
      expect(Validators.validateUsername('user name'), isNotNull); // Space
      expect(Validators.validateUsername('user-name'), isNotNull); // Hyphen
      expect(Validators.validateUsername('user@name'), isNotNull); // Special char
      expect(Validators.validateUsername('user.name'), isNotNull); // Period
    });

    test('should accept username with only alphanumeric and underscore', () {
      expect(Validators.validateUsername('user_123_name'), isNull);
      expect(Validators.validateUsername('test_user'), isNull);
      expect(Validators.validateUsername('abc123'), isNull);
    });
  });

  group('Validators - Item Title', () {
    test('should return null for valid title', () {
      expect(Validators.validateTitle('Drill'), isNull);
      expect(Validators.validateTitle('Cordless Power Drill'), isNull);
      expect(Validators.validateTitle('24ft Extension Ladder'), isNull);
    });

    test('should return error for empty title', () {
      expect(Validators.validateTitle(''), isNotNull);
      expect(Validators.validateTitle(null), isNotNull);
    });

    test('should return error for title shorter than 3 characters', () {
      expect(Validators.validateTitle('ab'), isNotNull);
      expect(Validators.validateTitle('x'), isNotNull);
    });

    test('should return error for title longer than 60 characters', () {
      final longTitle = 'a' * 61;
      expect(Validators.validateTitle(longTitle), isNotNull);
    });

    test('should accept title up to 60 characters', () {
      final maxTitle = 'a' * 60;
      expect(Validators.validateTitle(maxTitle), isNull);
    });
  });

  group('Validators - Item Description', () {
    test('should return null for valid description', () {
      expect(Validators.validateDescription('Great condition'), isNull);
      expect(Validators.validateDescription(''), isNull); // Optional field
      expect(Validators.validateDescription(null), isNull);
    });

    test('should return error for description longer than 500 characters', () {
      final longDescription = 'a' * 501;
      expect(Validators.validateDescription(longDescription), isNotNull);
    });

    test('should accept description up to 500 characters', () {
      final maxDescription = 'a' * 500;
      expect(Validators.validateDescription(maxDescription), isNull);
    });
  });

  group('Validators - Bio', () {
    test('should return null for valid bio', () {
      expect(Validators.validateBio('Love sharing!'), isNull);
      expect(Validators.validateBio(''), isNull); // Optional
      expect(Validators.validateBio(null), isNull);
    });

    test('should return error for bio longer than 500 characters', () {
      final longBio = 'a' * 501;
      expect(Validators.validateBio(longBio), isNotNull);
    });

    test('should accept bio up to 500 characters', () {
      final maxBio = 'a' * 500;
      expect(Validators.validateBio(maxBio), isNull);
    });
  });

  group('Validators - Message', () {
    test('should return null for valid message', () {
      expect(Validators.validateMessage('Hello!'), isNull);
      expect(Validators.validateMessage('How are you?'), isNull);
    });

    test('should return error for empty message', () {
      expect(Validators.validateMessage(''), isNotNull);
      expect(Validators.validateMessage(null), isNotNull);
      expect(Validators.validateMessage('   '), isNotNull); // Only whitespace
    });

    test('should return error for message longer than max length', () {
      final longMessage = 'a' * 1001;
      expect(Validators.validateMessage(longMessage), isNotNull);
    });
  });

  group('Validators - Required Field', () {
    test('should return null for non-empty value', () {
      expect(Validators.validateRequired('Some value', 'Field'), isNull);
    });

    test('should return error for empty value', () {
      expect(Validators.validateRequired('', 'Field'), isNotNull);
      expect(Validators.validateRequired(null, 'Field'), isNotNull);
      expect(Validators.validateRequired('   ', 'Field'), isNotNull);
    });

    test('should include field name in error message', () {
      final error = Validators.validateRequired('', 'Email');
      expect(error, contains('Email'));
    });
  });

  group('Validators - URL', () {
    test('should return true for valid URLs', () {
      expect(Validators.isValidUrl('https://example.com'), isTrue);
      expect(Validators.isValidUrl('http://example.com'), isTrue);
      expect(Validators.isValidUrl('https://sub.example.com/path'), isTrue);
    });

    test('should return false for invalid URLs', () {
      expect(Validators.isValidUrl(''), isFalse);
      expect(Validators.isValidUrl(null), isFalse);
      expect(Validators.isValidUrl('not-a-url'), isFalse);
      expect(Validators.isValidUrl('ftp://example.com'), isFalse);
    });
  });
}
