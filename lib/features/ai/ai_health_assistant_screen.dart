import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/repository.dart';
import '../../core/constants/mock_data.dart';
import 'package:intl/intl.dart';

class AIHealthAssistantScreen extends StatefulWidget {
  const AIHealthAssistantScreen({super.key});

  @override
  State<AIHealthAssistantScreen> createState() => _AIHealthAssistantScreenState();
}

class _AIHealthAssistantScreenState extends State<AIHealthAssistantScreen> {
  final _repository = MediVaultRepository();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _suggestions = [
    "Metformin side effects?",
    "Does Lipitor interact with Metformin?",
    "How to take Lisinopril?",
    "What should I do in a health emergency?",
  ];

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onRepositoryUpdated);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryUpdated);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onRepositoryUpdated() {
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage([String? text]) {
    final msg = text ?? _textController.text.trim();
    if (msg.isNotEmpty) {
      if (text == null) _textController.clear();
      
      setState(() {
        _isTyping = true;
      });
      _repository.sendChatMessage(msg);
      
      // Simulate typing indicator timeout matching repo delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Health Assistant"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
                  title: const Text("Medical Disclaimer"),
                  content: const Text(
                    "MediVault AI is designed to assist you in simplifying prescriptions and understanding general guidelines. It does NOT provide certified medical advice. In critical situations, consult a physical practitioner or reference your Emergency Card.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Understand"),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: GradientBackground(
        style: BackgroundStyle.aiStars,
        child: Column(
          children: [
            // Chat Message Stream List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _repository.chatHistory.length,
                itemBuilder: (context, index) {
                  final chat = _repository.chatHistory[index];
                  return _buildChatBubble(chat, isDark);
                },
              ),
            ),

            // Typing Indicator
            if (_isTyping) _buildTypingIndicator(isDark),

            // Suggestions slider
            _buildSuggestionsSlider(),

            // Chat Input Controls
            _buildInputControls(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage chat, bool isDark) {
    final timeStr = DateFormat('hh:mm a').format(chat.timestamp);
    
    return Align(
      alignment: chat.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: chat.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (chat.isUser)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: Text(
                  chat.message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              )
            else
              GlassCard(
                padding: const EdgeInsets.all(14),
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                child: Text(
                  chat.message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                timeStr,
                style: const TextStyle(fontSize: 9, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          width: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              return Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsSlider() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final s = _suggestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(s, style: const TextStyle(fontSize: 12)),
              backgroundColor: AppTheme.primaryGreen.withAlpha(15),
              side: BorderSide(color: AppTheme.primaryGreen.withAlpha(30)),
              onPressed: () => _sendMessage(s),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputControls(bool isDark) {
    final bg = isDark ? AppTheme.surfaceDark : Colors.white;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg.withAlpha(200),
        border: Border(top: BorderSide(color: Colors.grey.withAlpha(40))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Ask about your medications or side effects...",
                hintStyle: const TextStyle(fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                fillColor: (isDark ? Colors.white : Colors.black).withAlpha(15),
                filled: true,
              ),
              onFieldSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppTheme.primaryGreen,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: () => _sendMessage(),
            ),
          )
        ],
      ),
    );
  }
}
