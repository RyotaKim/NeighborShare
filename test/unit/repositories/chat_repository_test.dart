import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/features/chat/data/repositories/chat_repository.dart';
import 'package:flutter_application_1/features/chat/data/models/message_model.dart';
import 'package:flutter_application_1/features/chat/data/models/conversation_model.dart';
import 'package:flutter_application_1/core/errors/app_exception.dart';

@GenerateMocks([SupabaseClient, SupabaseQueryBuilder, PostgrestFilterBuilder])
import 'chat_repository_test.mocks.dart';

void main() {
  late MockSupabaseClient mockSupabase;
  late ChatRepository repository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    repository = ChatRepository(mockSupabase);
  });

  group('ChatRepository - Create Conversation', () {
    test('should successfully create a new conversation', () async {
      // Arrange
      final itemId = 'item-123';
      final userId1 = 'user-1';
      final userId2 = 'user-2';

      final mockConversationData = {
        'id': 'conv-123',
        'item_id': itemId,
        'created_at': DateTime.now().toIso8601String(),
        'last_message_at': DateTime.now().toIso8601String(),
      };

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('conversations')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.insert(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.single()).thenAnswer((_) async => mockConversationData);

      // Mock participant inserts
      when(mockSupabase.from('conversation_participants')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.insert(any)).thenAnswer((_) async => []);

      // Act
      final result = await repository.createConversation(itemId, userId1, userId2);

      // Assert
      expect(result.id, equals('conv-123'));
      expect(result.itemId, equals(itemId));
      verify(mockSupabase.from('conversations')).called(greaterThan(0));
    });

    test('should throw DatabaseException when creation fails', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();

      when(mockSupabase.from('conversations')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.insert(any)).thenThrow(
        PostgrestException(message: 'Insert failed'),
      );

      // Act & Assert
      expect(
        () => repository.createConversation('item-123', 'user-1', 'user-2'),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('ChatRepository - Get User Conversations', () {
    test('should return list of user conversations', () async {
      // Arrange
      final userId = 'user-123';
      final mockData = [
        {
          'id': 'conv-1',
          'item_id': 'item-1',
          'created_at': DateTime.now().toIso8601String(),
          'last_message_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'conv-2',
          'item_id': 'item-2',
          'created_at': DateTime.now().toIso8601String(),
          'last_message_at': DateTime.now().toIso8601String(),
        },
      ];

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('conversation_participants')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('user_id', userId)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.order('last_message_at', ascending: false))
          .thenAnswer((_) async => mockData);

      // Act
      final result = await repository.getUserConversations(userId);

      // Assert
      expect(result, isA<List<ConversationModel>>());
      expect(result.length, equals(2));
    });

    test('should return empty list when user has no conversations', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('conversation_participants')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('user_id', 'user-123')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.order('last_message_at', ascending: false))
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getUserConversations('user-123');

      // Assert
      expect(result, isEmpty);
    });
  });

  group('ChatRepository - Send Message', () {
    test('should successfully send a message', () async {
      // Arrange
      final message = MessageModel(
        id: 'msg-123',
        conversationId: 'conv-123',
        senderId: 'user-123',
        content: 'Hello!',
        createdAt: DateTime.now(),
      );

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('messages')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.insert(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.single()).thenAnswer((_) async => message.toJson());

      // Act
      final result = await repository.sendMessage(message);

      // Assert
      expect(result.id, equals('msg-123'));
      expect(result.content, equals('Hello!'));
      verify(mockSupabase.from('messages')).called(1);
    });

    test('should throw DatabaseException when send fails', () async {
      // Arrange
      final message = MessageModel(
        id: 'msg-123',
        conversationId: 'conv-123',
        senderId: 'user-123',
        content: 'Hello!',
        createdAt: DateTime.now(),
      );

      final mockQueryBuilder = MockSupabaseQueryBuilder();

      when(mockSupabase.from('messages')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.insert(any)).thenThrow(
        PostgrestException(message: 'Send failed'),
      );

      // Act & Assert
      expect(
        () => repository.sendMessage(message),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('ChatRepository - Get Messages', () {
    test('should return messages for a conversation', () async {
      // Arrange
      final conversationId = 'conv-123';
      final mockData = [
        {
          'id': 'msg-1',
          'conversation_id': conversationId,
          'sender_id': 'user-1',
          'content': 'Hello!',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': 'msg-2',
          'conversation_id': conversationId,
          'sender_id': 'user-2',
          'content': 'Hi there!',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('messages')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('conversation_id', conversationId))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.order('created_at', ascending: true))
          .thenAnswer((_) async => mockData);

      // Act
      final result = await repository.getMessages(conversationId);

      // Assert
      expect(result, isA<List<MessageModel>>());
      expect(result.length, equals(2));
      expect(result[0].content, equals('Hello!'));
      expect(result[1].content, equals('Hi there!'));
    });

    test('should return empty list for conversation with no messages', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('messages')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('conversation_id', 'empty-conv'))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.order('created_at', ascending: true))
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getMessages('empty-conv');

      // Assert
      expect(result, isEmpty);
    });
  });

  group('ChatRepository - Get Conversation by Item', () {
    test('should return existing conversation for item and users', () async {
      // Arrange
      final itemId = 'item-123';
      final userId1 = 'user-1';
      final userId2 = 'user-2';

      final mockData = {
        'id': 'conv-123',
        'item_id': itemId,
        'created_at': DateTime.now().toIso8601String(),
        'last_message_at': DateTime.now().toIso8601String(),
      };

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('conversations')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('item_id', itemId)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockData);

      // Act
      final result = await repository.getConversationByItem(itemId, userId1, userId2);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals('conv-123'));
      expect(result.itemId, equals(itemId));
    });

    test('should return null when no conversation exists', () async {
      // Arrange
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('conversations')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('item_id', 'item-123')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => null);

      // Act
      final result = await repository.getConversationByItem('item-123', 'user-1', 'user-2');

      // Assert
      expect(result, isNull);
    });
  });

  group('ChatRepository - Delete Conversation', () {
    test('should successfully delete a conversation', () async {
      // Arrange
      final conversationId = 'conv-123';
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(mockSupabase.from('conversations')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', conversationId)).thenAnswer((_) async => {});

      // Act
      await repository.deleteConversation(conversationId);

      // Assert
      verify(mockSupabase.from('conversations')).called(1);
      verify(mockQueryBuilder.delete()).called(1);
    });
  });
}
