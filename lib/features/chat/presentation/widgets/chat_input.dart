import 'package:flutter/material.dart';

/// Chat input widget matching mockup:
/// - Text field with "Type a message..." placeholder
/// - Attachment icon (paperclip)
/// - Green circular send button
class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isSending;
  final int maxLength;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isSending = false,
    this.maxLength = 1000,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;

    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input with attachment icon
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Text field
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        maxLength: widget.maxLength,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          counterText: '',
                          filled: false,
                        ),
                      ),
                    ),

                    // Attachment icon
                    Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 4),
                      child: IconButton(
                        icon: Icon(
                          Icons.attach_file_rounded,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          size: 20,
                        ),
                        onPressed: () {
                          // TODO: Implement attachment picking
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Attachments coming soon!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Green circular send button
            SizedBox(
              width: 44,
              height: 44,
              child: Material(
                color: _hasText && !widget.isSending
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _hasText && !widget.isSending ? _handleSend : null,
                  customBorder: const CircleBorder(),
                  child: Center(
                    child: widget.isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: _hasText && !widget.isSending
                                ? Colors.white
                                : colorScheme.onSurfaceVariant,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
