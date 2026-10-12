import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isUrgent;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isUrgent = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class PatientChatbotScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;

  const PatientChatbotScreen({super.key, this.onBackToDashboard});

  @override
  State<PatientChatbotScreen> createState() => _PatientChatbotScreenState();
}

class _PatientChatbotScreenState extends State<PatientChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickSuggestions = [
    'My Heart Rate status',
    'When is my next medicine?',
    'I feel dizzy / unwell',
    'Hydration reminder',
    'Tips for better sleep',
    'Call my caregiver',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: 'Hello! I am your CareVoice Assistant. I am here to help answer health questions, track your schedule, and keep you safe. How are you feeling right now?',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage([String? presetText]) {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _textController.clear();
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    // Generate intelligent contextual response
    Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final reply = _generateBotReply(text);
      setState(() {
        _isTyping = false;
        _messages.add(reply);
      });
      _scrollToBottom();
    });
  }

  ChatMessage _generateBotReply(String userQuery) {
    final query = userQuery.toLowerCase();

    if (query.contains('heart') || query.contains('bpm') || query.contains('pulse')) {
      return ChatMessage(
        text: 'Your current heart rate is reading at 74 BPM (Demo Data). This is within the normal resting adult range of 60 to 100 BPM. Keep resting calmly and let me know if you feel any palpitations.',
        isUser: false,
      );
    } else if (query.contains('dizzy') || query.contains('unwell') || query.contains('pain') || query.contains('hurt') || query.contains('chest') || query.contains('emergency') || query.contains('fall')) {
      return ChatMessage(
        text: 'I am concerned about your symptom. Please sit or lie down comfortably in a safe place immediately. If you need urgent assistance, tap the "Alert Caregiver" button below.',
        isUser: false,
        isUrgent: true,
      );
    } else if (query.contains('medicine') || query.contains('medication') || query.contains('pill') || query.contains('dose')) {
      return ChatMessage(
        text: 'Your scheduled reminders indicate morning and evening doses are tracked on your dashboard. Please take them with a full glass of water and check off your reminder.',
        isUser: false,
      );
    } else if (query.contains('water') || query.contains('hydration') || query.contains('thirst')) {
      return ChatMessage(
        text: 'Staying well hydrated is essential for stable blood circulation and body temperature. Aim for 6-8 glasses of water daily, sipping steadily throughout the day.',
        isUser: false,
      );
    } else if (query.contains('caregiver') || query.contains('call') || query.contains('doctor') || query.contains('help')) {
      return ChatMessage(
        text: 'Your assigned caregiver has been linked to this account. You can trigger an instant notification or emergency call at any time from the app.',
        isUser: false,
        isUrgent: true,
      );
    } else if (query.contains('sleep') || query.contains('tired') || query.contains('rest')) {
      return ChatMessage(
        text: 'For restorative sleep, keep your room cool, dim lights 30 minutes before bed, and avoid caffeine in the afternoon. Rest is vital for patient recovery.',
        isUser: false,
      );
    } else if (query.contains('hello') || query.contains('hi') || query.contains('hey')) {
      return ChatMessage(
        text: 'Hello! I am ready to assist you. You can ask about your vitals, reminders, or how you are feeling today.',
        isUser: false,
      );
    } else {
      return ChatMessage(
        text: 'Thank you for reaching out. I have recorded your message. Remember to rest, take scheduled medications on time, and reach out to your caregiver if you feel any distress.',
        isUser: false,
      );
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(
        ChatMessage(
          text: 'Conversation cleared. How can I help you right now?',
          isUser: false,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar / Header Card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: context.isDark ? 0.25 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CareVoice Assistant',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.emerald500,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'AI Health Companion · Online',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Reset Conversation',
                    icon: Icon(Icons.refresh_rounded, color: context.textSecondaryColor, size: 20),
                    onPressed: _clearChat,
                  ),
                ],
              ),
            ),

            // Quick Suggestions Chips
            Container(
              height: 38,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _quickSuggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final suggestion = _quickSuggestions[index];
                  return ActionChip(
                    label: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    backgroundColor: context.surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: context.borderColor),
                    ),
                    onPressed: () => _handleSendMessage(suggestion),
                  );
                },
              ),
            ),

            // Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // Typing Indicator
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, size: 6, color: AppColors.indigo400)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .fade(duration: 400.ms),
                          const SizedBox(width: 4),
                          const Icon(Icons.circle, size: 6, color: AppColors.indigo500)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .fade(delay: 150.ms, duration: 400.ms),
                          const SizedBox(width: 4),
                          const Icon(Icons.circle, size: 6, color: AppColors.indigo600)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .fade(delay: 300.ms, duration: 400.ms),
                          const SizedBox(width: 8),
                          Text(
                            'CareBot is typing...',
                            style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // 100px bottom padding for custom floating navbar
              decoration: BoxDecoration(
                color: context.surfaceColor.withValues(alpha: 0.95),
                border: Border(top: BorderSide(color: context.borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.subtleBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              style: TextStyle(fontSize: 14, color: context.textPrimaryColor),
                              decoration: InputDecoration(
                                hintText: 'Ask CareBot anything...',
                                hintStyle: TextStyle(fontSize: 13, color: context.textSecondaryColor),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: (_) => _handleSendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.mic_none_rounded, size: 20, color: AppColors.indigo400),
                            tooltip: 'Voice Prompt (Demo)',
                            onPressed: () {
                              _handleSendMessage('I need a quick health checkup');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.indigo500.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _handleSendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.indigo500.withValues(alpha: 0.15),
                  child: const Icon(Icons.smart_toy_rounded, size: 16, color: AppColors.indigo500),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.indigo500
                        : (msg.isUrgent ? AppColors.rose500.withValues(alpha: 0.12) : context.surfaceColor),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    border: Border.all(
                      color: isUser
                          ? Colors.transparent
                          : (msg.isUrgent ? AppColors.rose500.withValues(alpha: 0.4) : context.borderColor),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: isUser
                              ? Colors.white
                              : (msg.isUrgent ? AppColors.rose500 : context.textPrimaryColor),
                          fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                      if (msg.isUrgent) ...[
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            apiClient.voiceSos('Patient requested help from Chatbot interface');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.rose500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.emergency_rounded, size: 16),
                          label: const Text('ALERT CAREGIVER NOW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.indigo500,
                  child: const Icon(Icons.person, size: 16, color: Colors.white),
                ),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 3,
              left: isUser ? 0 : 36,
              right: isUser ? 36 : 0,
            ),
            child: Text(
              '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 10, color: context.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
