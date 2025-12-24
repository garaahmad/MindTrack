import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hugging_face_service.dart';
import 'theme_service.dart';
import 'dart:ui';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final ThemeService _themeService = ThemeService();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Hello! I'm your AI companion. How are you feeling today? I'm here to listen and help you reflect on your journey.",
      isUser: false,
      time: DateTime.now(),
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, time: DateTime.now()),
      );
      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final hfService = HuggingFaceService();

      final history = _messages
          .map(
            (msg) => {
              "role": msg.isUser ? "user" : "assistant",
              "content": msg.text,
            },
          )
          .toList();

      final aiResponse = await hfService.getChatResponse(history);

      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(text: aiResponse, isUser: false, time: DateTime.now()),
          );
          _isTyping = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text:
                  "I'm having a little trouble connecting. Please check your settings.",
              isUser: false,
              time: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = _themeService.primaryColor;
    final backgroundColor = _themeService.backgroundColor;
    final surfaceColor = _themeService.surfaceColor;
    final textColor = _themeService.textColor;
    final isDark = _themeService.isDark;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, primaryColor, textColor),

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(
                        msg,
                        primaryColor,
                        surfaceColor,
                        textColor,
                        isDark,
                      );
                    },
                  ),
                ),

                if (_isTyping)
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          "AI is thinking...",
                          style: GoogleFonts.manrope(
                            color: primaryColor.withOpacity(0.7),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildInputArea(primaryColor, surfaceColor, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color primaryColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          ),
          Column(
            children: [
              Text(
                'AI Companion',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Online',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.info_outline, color: textColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessage msg,
    Color primary,
    Color surface,
    Color textColor,
    bool isDark,
  ) {
    final bubbleColor = msg.isUser ? primary : surface;
    final bubbleTextColor = msg.isUser
        ? (isDark ? Colors.black : Colors.white)
        : textColor;

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: bubbleColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          msg.text,
          style: GoogleFonts.manrope(
            color: bubbleTextColor,
            fontSize: 15,
            fontWeight: msg.isUser ? FontWeight.w600 : FontWeight.w500,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(Color primary, Color surface, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface.withOpacity(0.5),
        border: Border(top: BorderSide(color: textColor.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: textColor.withOpacity(0.05)),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.manrope(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: GoogleFonts.manrope(
                    color: textColor.withOpacity(0.4),
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.send_rounded,
                color: _themeService.isDark ? Colors.black : Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
