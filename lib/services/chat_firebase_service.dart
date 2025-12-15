import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _conversationsKey = 'chat_conversations';
  static const String _currentConversationKey = 'current_conversation';

  /// حفظ رسالة في المحادثة
  Future<void> saveMessage({
    required String message,
    required bool isUser,
    required String conversationId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // حفظ في Firebase للمستخدم المسجل
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .add({
          'message': message,
          'isUser': isUser,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // تحديث وقت آخر رسالة في المحادثة
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('conversations')
            .doc(conversationId)
            .update({
          'lastMessage': message,
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      } else {
        // حفظ محلياً للمستخدم الضيف
        await _saveMessageLocally(message, isUser, conversationId);
      }
    } catch (e) {
      print('Error saving message: $e');
      // في حالة الخطأ، نحاول الحفظ محلياً
      await _saveMessageLocally(message, isUser, conversationId);
    }
  }

  /// حفظ الرسالة محلياً
  Future<void> _saveMessageLocally(String message, bool isUser, String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversations = prefs.getStringList(_conversationsKey) ?? [];
      
      // البحث عن المحادثة الحالية
      String conversationJson = '';
      for (int i = 0; i < conversations.length; i++) {
        if (conversations[i].contains('"id":"$conversationId"')) {
          conversationJson = conversations[i];
          conversations.removeAt(i);
          break;
        }
      }

      Map<String, dynamic> conversationData;
      if (conversationJson.isNotEmpty) {
        conversationData = Map<String, dynamic>.from(
          json.decode(conversationJson)
        );
      } else {
        conversationData = {
          'id': conversationId,
          'createdAt': DateTime.now().toIso8601String(),
          'lastMessage': message,
          'lastMessageTime': DateTime.now().toIso8601String(),
          'messages': <Map<String, dynamic>>[],
        };
      }

      // إضافة الرسالة الجديدة
      final messages = List<Map<String, dynamic>>.from(conversationData['messages'] ?? []);
      messages.add({
        'message': message,
        'isUser': isUser,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      conversationData['messages'] = messages;
      conversationData['lastMessage'] = message;
      conversationData['lastMessageTime'] = DateTime.now().toIso8601String();

      // حفظ المحادثة المحدثة
      conversations.add(json.encode(conversationData));
      await prefs.setStringList(_conversationsKey, conversations);
      
      // حفظ الـ ID الحالي
      await prefs.setString(_currentConversationKey, conversationId);
    } catch (e) {
      print('Error saving message locally: $e');
    }
  }

  /// إنشاء محادثة جديدة
  Future<String> createConversation() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // إنشاء في Firebase للمستخدم المسجل
        final docRef = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('conversations')
            .add({
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });

        return docRef.id;
      } else {
        // إنشاء محلياً للمستخدم الضيف
        return await _createConversationLocally();
      }
    } catch (e) {
      print('Error creating conversation: $e');
      // في حالة الخطأ، ننشئ محلياً
      return await _createConversationLocally();
    }
  }

  /// إنشاء محادثة جديدة محلياً
  Future<String> _createConversationLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversations = prefs.getStringList(_conversationsKey) ?? [];
      
      final conversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
      final conversationData = {
        'id': conversationId,
        'createdAt': DateTime.now().toIso8601String(),
        'lastMessage': '',
        'lastMessageTime': DateTime.now().toIso8601String(),
        'messages': <Map<String, dynamic>>[],
      };

      conversations.add(json.encode(conversationData));
      await prefs.setStringList(_conversationsKey, conversations);
      await prefs.setString(_currentConversationKey, conversationId);
      
      return conversationId;
    } catch (e) {
      print('Error creating conversation locally: $e');
      rethrow;
    }
  }

  /// جلب آخر محادثة للمستخدم
  Future<String?> getLastConversation() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // جلب من Firebase للمستخدم المسجل
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('conversations')
            .orderBy('lastMessageTime', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) return null;
        return snapshot.docs.first.id;
      } else {
        // جلب محلياً للمستخدم الضيف
        return await _getLastConversationLocally();
      }
    } catch (e) {
      print('Error getting last conversation: $e');
      // في حالة الخطأ، نحاول محلياً
      return await _getLastConversationLocally();
    }
  }

  /// جلب آخر محادثة محلياً
  Future<String?> _getLastConversationLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // محاولة جلب المحادثة الحالية أولاً
      final currentId = prefs.getString(_currentConversationKey);
      if (currentId != null) return currentId;
      
      // إذا مش موجود، نبحث عن آخر محادثة
      final conversations = prefs.getStringList(_conversationsKey) ?? [];
      if (conversations.isEmpty) return null;
      
      String? latestConversationId;
      DateTime? latestTime;
      
      for (final conversationJson in conversations) {
        try {
          final data = Map<String, dynamic>.from(
            json.decode(conversationJson)
          );
          
          final timeStr = data['lastMessageTime'] as String?;
          if (timeStr != null) {
            final time = DateTime.parse(timeStr);
            if (latestTime == null || time.isAfter(latestTime)) {
              latestTime = time;
              latestConversationId = data['id'] as String?;
            }
          }
        } catch (e) {
          print('Error parsing conversation: $e');
        }
      }
      
      return latestConversationId;
    } catch (e) {
      print('Error getting last conversation locally: $e');
      return null;
    }
  }

  /// جلب رسائل محادثة معينة
  Future<List<Map<String, dynamic>>> getConversationMessages(
      String conversationId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // جلب من Firebase للمستخدم المسجل
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('conversations')
            .doc(conversationId)
            .collection('messages')
            .orderBy('timestamp')
            .get();

        return snapshot.docs.map((doc) => doc.data()).toList();
      } else {
        // جلب محلياً للمستخدم الضيف
        return await _getConversationMessagesLocally(conversationId);
      }
    } catch (e) {
      print('Error getting conversation messages: $e');
      // في حالة الخطأ، نحاول محلياً
      return await _getConversationMessagesLocally(conversationId);
    }
  }

  /// جلب رسائل محادثة محلياً
  Future<List<Map<String, dynamic>>> _getConversationMessagesLocally(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversations = prefs.getStringList(_conversationsKey) ?? [];
      
      for (final conversationJson in conversations) {
        if (conversationJson.contains('"id":"$conversationId"')) {
          final data = Map<String, dynamic>.from(
            json.decode(conversationJson)
          );
          
          final messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);
          
          // ترتيب الرسائل حسب الوقت
          messages.sort((a, b) {
            final timeA = DateTime.parse(a['timestamp'] as String);
            final timeB = DateTime.parse(b['timestamp'] as String);
            return timeA.compareTo(timeB);
          });
          
          return messages;
        }
      }
      
      return [];
    } catch (e) {
      print('Error getting conversation messages locally: $e');
      return [];
    }
  }

  /// جلب كل المحادثات للمستخدم
  Future<List<Map<String, dynamic>>> getUserConversations() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting user conversations: $e');
      return [];
    }
  }

  /// حذف محادثة
  Future<void> deleteConversation(String conversationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // حذف الرسائل أولاً
      final messagesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      for (final doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // حذف المحادثة
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .doc(conversationId)
          .delete();
    } catch (e) {
      print('Error deleting conversation: $e');
    }
  }
}
