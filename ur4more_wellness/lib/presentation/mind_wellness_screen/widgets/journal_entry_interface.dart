import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

class JournalEntryInterface extends StatefulWidget {
  final Function(String) onEntryChanged;
  final Function() onSaveEntry;
  final String initialText;

  const JournalEntryInterface({
    super.key,
    required this.onEntryChanged,
    required this.onSaveEntry,
    this.initialText = '',
  });

  @override
  State<JournalEntryInterface> createState() => _JournalEntryInterfaceState();
}

class _JournalEntryInterfaceState extends State<JournalEntryInterface> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _isExpanded = false;
  int _characterCount = 0;
  static const int _maxCharacters = 2000;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    _characterCount = widget.initialText.length;

    _textController.addListener(() {
      setState(() {
        _characterCount = _textController.text.length;
      });
      widget.onEntryChanged(_textController.text);
    });

    _focusNode.addListener(() {
      setState(() {
        _isExpanded = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: Pad.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'edit_note',
                    color: const Color(0xFF0FA97A),
                    size: 20,
                  ),
                  SizedBox(width: AppSpace.x2),
                  Text(
                    'Journal Entry',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (_textController.text.isNotEmpty)
                    TextButton(
                      onPressed: widget.onSaveEntry,
                      child: Text(
                        'Save',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF0FA97A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppSpace.x3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                constraints: BoxConstraints(
                  minHeight: _isExpanded ? 200 : 120,
                  maxHeight: _isExpanded ? 300 : 120,
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  maxLength: _maxCharacters,
                  textInputAction: TextInputAction.newline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Share your thoughts, feelings, and reflections...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity( 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity( 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: const Color(0xFF0FA97A),
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.all(AppSpace.x3),
                    counterText: '',
                  ),
                ),
              ),
              SizedBox(height: AppSpace.x2),
              Row(
                children: [
                  Text(
                    'Auto-saved',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: AppSpace.x2),
                  CustomIconWidget(
                    iconName: 'cloud_done',
                    color: const Color(0xFF0FA97A),
                    size: 14,
                  ),
                  const Spacer(),
                  Text(
                    '$_characterCount/$_maxCharacters',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _characterCount > _maxCharacters * 0.9
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
