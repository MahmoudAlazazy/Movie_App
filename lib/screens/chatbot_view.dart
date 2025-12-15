import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../chatbot/chatbot_service.dart';
import '../services/chat_firebase_service.dart';

class ChatBotView extends StatefulWidget {
  const ChatBotView({super.key});

  @override
  State<ChatBotView> createState() => _ChatBotViewState();
}

class _ChatBotViewState extends State<ChatBotView> {
  final ChatBotService _botService = ChatBotService();
  final ChatFirebaseService _firebaseService = ChatFirebaseService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;

  final List<_ChatMessage> _messages = [];
  String? _conversationId;
  bool _isLoading = false;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _botService.loadData();
    _initializeSpeech();
    _initializeChat();

    // مراقبة التغيير في الـ TextField
    _controller.addListener(() {
      setState(() {});
    });
  }

  /// تهيئة خدمة التعرف على الصوت
  Future<void> _initializeSpeech() async {
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
    setState(() {});
  }

  /// تهيئة الشات وتحميل المحادثة السابقة إن وجدت
  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);

    try {
      _conversationId = await _firebaseService.getLastConversation();

      if (_conversationId != null) {
        final messages =
            await _firebaseService.getConversationMessages(_conversationId!);

        setState(() {
          _messages.clear();
          for (var msgData in messages) {
            _messages.add(_ChatMessage(
              text: msgData['message'] ?? '',
              isUser: msgData['isUser'] ?? false,
            ));
          }
        });
      } else {
        _conversationId = await _firebaseService.createConversation();
        _addBotMessage(
          '🎬 أهلاً بيك!\nقولّي مثلاً: عاوز فيلم أكشن أو فيلم زي Avatar',
          saveToFirebase: true,
        );
      }
    } catch (e) {
      print('Error initializing chat: $e');
      _addBotMessage(
        '🎬 أهلاً بيك!\nقولّي مثلاً: عاوز فيلم أكشن أو فيلم زي Avatar',
        saveToFirebase: false,
      );
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _addUserMessage(String text, {bool saveToFirebase = true}) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });

    if (saveToFirebase && _conversationId != null) {
      _firebaseService.saveMessage(
        message: text,
        isUser: true,
        conversationId: _conversationId!,
      );
    }

    _scrollToBottom();
  }

  void _addBotMessage(String text, {bool saveToFirebase = true}) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: false));
    });

    if (saveToFirebase && _conversationId != null) {
      _firebaseService.saveMessage(
        message: text,
        isUser: false,
        conversationId: _conversationId!,
      );
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _addUserMessage(text);

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    final reply = _botService.reply(text);
    _addBotMessage(reply);

    setState(() => _isLoading = false);
  }

  /// بدء/إيقاف التسجيل الصوتي
  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خدمة التعرف على الصوت غير متاحة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isListening) {
      // إيقاف التسجيل
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      // بدء التسجيل
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
        localeId: 'ar_EG', // اللغة العربية
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  /// بدء محادثة جديدة
  Future<void> _startNewConversation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'محادثة جديدة',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'هل تريد بدء محادثة جديدة؟',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _messages.clear();
        _isLoading = true;
      });

      try {
        _conversationId = await _firebaseService.createConversation();
        _addBotMessage(
          '🎬 أهلاً بيك!\nقولّي مثلاً: عاوز فيلم أكشن أو فيلم زي Avatar',
        );
      } catch (e) {
        print('Error creating new conversation: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        title: const Text('Movie Recommendation Bot 🎥'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'محادثة جديدة',
            onPressed: _startNewConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2563EB),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _ChatBubble(message: msg);
                    },
                  ),
          ),
          if (_isListening)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1E293B),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PulsingMicIcon(),
                  const SizedBox(width: 12),
                  const Text(
                    'جاري الاستماع...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (_isLoading && _messages.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TypingDot(delay: 0),
                    const SizedBox(width: 4),
                    _TypingDot(delay: 200),
                    const SizedBox(width: 4),
                    _TypingDot(delay: 400),
                  ],
                ),
              ),
            ),
          _InputBar(
            controller: _controller,
            onSend: _sendMessage,
            onMicPressed: _toggleListening,
            isListening: _isListening,
            enabled: !_isLoading,
            hasText: _controller.text.isNotEmpty,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _speech.cancel();
    super.dispose();
  }
}

// ===============================
// Models
// ===============================
class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

// ===============================
// Chat Bubble
// ===============================
class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white, height: 1.4),
        ),
      ),
    );
  }
}

// ===============================
// Input Bar
// ===============================
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onMicPressed;
  final bool isListening;
  final bool enabled;
  final bool hasText;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onMicPressed,
    required this.isListening,
    required this.hasText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF020617),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled && !isListening,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'اكتب أو اضغط على المايك...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: enabled && hasText ? (_) => onSend() : null,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: enabled ? (hasText ? onSend : onMicPressed) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: enabled
                    ? (isListening
                        ? Colors.red
                        : const Color(0xFF2563EB))
                    : const Color(0xFF1E293B),
                shape: BoxShape.circle,
                boxShadow: isListening
                    ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                hasText ? Icons.send : (isListening ? Icons.stop : Icons.mic),
                color: enabled ? Colors.white : Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================
// Typing Indicator Dot
// ===============================
class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white70,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ===============================
// Pulsing Mic Icon
// ===============================
class _PulsingMicIcon extends StatefulWidget {
  @override
  State<_PulsingMicIcon> createState() => _PulsingMicIconState();
}

class _PulsingMicIconState extends State<_PulsingMicIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: const Icon(
        Icons.mic,
        color: Colors.red,
        size: 32,
      ),
    );
  }
}