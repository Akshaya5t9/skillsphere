import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_tutor_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/api_key_dialog.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportChatNotes(BuildContext context, List<dynamic> messages) {
    final buffer = StringBuffer();
    buffer.writeln('# SkillSphere AI — Study Notes');
    buffer.writeln('Exported on: ${DateTime.now().toLocal()}\n');

    for (final m in messages) {
      buffer.writeln('### ${m.isUser ? "You" : "Lumina AI"}:');
      buffer.writeln('${m.text}\n');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full study notes copied in Markdown format!'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tutorProvider = Provider.of<AiTutorProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quickActionPills = [
      {'label': '💡 Explain Simply', 'prompt': 'Explain Flutter state management using a simple real-world analogy.'},
      {'label': '⚡ Dart Code Snippet', 'prompt': 'Show me a clean Flutter code snippet demonstrating async streams and FutureBuilder.'},
      {'label': '🐛 Debug Scenario', 'prompt': 'What are the top 3 common bugs in Flutter and how do I fix them?'},
      {'label': '📝 Flashcard Quiz', 'prompt': 'Test my knowledge with 3 quick interview questions on Dart and Flutter.'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppColors.aiGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lumina AI Tutor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  userProvider.hasApiKey ? '● Gemini 1.5 Online' : '● Smart Offline Ready',
                  style: TextStyle(
                    fontSize: 11,
                    color: userProvider.hasApiKey ? AppColors.accent : Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export Notes',
            onPressed: () => _exportChatNotes(context, tutorProvider.messages),
          ),
          IconButton(
            icon: const Icon(Icons.vpn_key_outlined, size: 20),
            tooltip: 'Gemini API Key',
            onPressed: () {
              showDialog(context: context, builder: (_) => const ApiKeyDialog());
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Clear Chat',
            onPressed: tutorProvider.clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Action Tools Carousel
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.5) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: quickActionPills.length,
              itemBuilder: (ctx, i) {
                final item = quickActionPills[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    label: Text(
                      item['label']!,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primaryLight),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                    onPressed: () {
                      tutorProvider.sendMessage(item['prompt']!);
                      _scrollToBottom();
                    },
                  ),
                );
              },
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: tutorProvider.messages.length,
              itemBuilder: (ctx, index) {
                final message = tutorProvider.messages[index];
                return _buildMessageItem(message, isDark);
              },
            ),
          ),

          // Typing Indicator
          if (tutorProvider.isGenerating)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                        SizedBox(width: 10),
                        Text('Lumina is synthesizing answer...', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Message Input Box
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        tutorProvider.sendMessage(val);
                        _inputController.clear();
                        _scrollToBottom();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Ask Lumina anything about Dart, Flutter, AI...',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.aiGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                    onPressed: () {
                      final text = _inputController.text.trim();
                      if (text.isNotEmpty) {
                        tutorProvider.sendMessage(text);
                        _inputController.clear();
                        _scrollToBottom();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(dynamic message, bool isDark) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                gradient: AppColors.aiGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primary
                        : (isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    border: !isUser
                        ? Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          )
                        : null,
                    boxShadow: AppColors.glassShadow(isDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser && message.isOfflineFallback)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.offline_bolt, size: 12, color: Colors.amber[300]),
                              const SizedBox(width: 4),
                              Text(
                                'Smart Offline Engine',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[300],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isUser)
                        Text(
                          message.text,
                          style: const TextStyle(color: Colors.white, fontSize: 14.5),
                        )
                      else
                        MarkdownBody(
                          data: message.text,
                          styleSheet: MarkdownStyleSheet.fromTheme(
                            ThemeData(
                              brightness: isDark ? Brightness.dark : Brightness.light,
                              textTheme: TextTheme(
                                bodyMedium: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ).copyWith(
                            code: TextStyle(
                              backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFE2E8F0),
                              fontFamily: 'monospace',
                              fontSize: 12.5,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0B0F19) : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 14),
                        tooltip: 'Copy Answer',
                        onPressed: () => _copyToClipboard(message.text),
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_up_outlined, size: 14),
                        tooltip: 'Helpful',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Feedback recorded!')),
                          );
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
