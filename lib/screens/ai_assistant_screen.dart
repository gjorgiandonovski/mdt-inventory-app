import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../services/ai_assistant_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiAssistantService _service = AiAssistantService();
  final List<_ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final strings = context.read<LanguageProvider>().strings;
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _messages.add(_ChatMessage(role: _ChatRole.user, text: text));
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final language = context.read<LanguageProvider>().language;
      final reply = await _service.ask(message: text, language: language);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(role: _ChatRole.assistant, text: reply));
      });
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('Missing Gemini API key')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.aiAssistantMissingKey)),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${strings.aiAssistantErrorPrefix}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;

    return Scaffold(
      appBar: AppBar(title: Text(strings.aiAssistantTitle)),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        strings.aiAssistantEmptyState,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message.role == _ChatRole.user;
                      final alignment =
                          isUser ? Alignment.centerRight : Alignment.centerLeft;
                      final color = isUser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white;
                      final textColor = isUser ? Colors.white : Colors.black87;
                      return Align(
                        alignment: alignment,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isSending)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(strings.aiAssistantThinking),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: strings.aiAssistantInputHint,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isSending ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChatRole { user, assistant }

class _ChatMessage {
  final _ChatRole role;
  final String text;

  const _ChatMessage({required this.role, required this.text});
}
