import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../services/speech_to_text_service.dart';
import '../services/web_speech_service.dart';

/// A universal text field with speech-to-text functionality
/// Works on both mobile and web platforms
class UniversalSpeechTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String localeId;
  final bool showSpeechButton;
  final IconData? speechIcon;
  final String? speechTooltip;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  const UniversalSpeechTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.localeId = 'en_US',
    this.showSpeechButton = true,
    this.speechIcon,
    this.speechTooltip,
    this.decoration,
    this.keyboardType,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<UniversalSpeechTextField> createState() => _UniversalSpeechTextFieldState();
}

class _UniversalSpeechTextFieldState extends State<UniversalSpeechTextField> {
  bool _isListening = false;
  String _currentSpeechText = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          textCapitalization: widget.textCapitalization,
          decoration: _buildDecoration(),
        ),
        
        // Speech functionality and status
        if (widget.showSpeechButton) ...[
          const SizedBox(height: 8),
          _buildSpeechControls(),
        ],
        
        // Listening indicator
        if (_isListening)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Listening...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  InputDecoration _buildDecoration() {
    return widget.decoration ?? InputDecoration(
      hintText: widget.hintText,
      labelText: widget.labelText,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildSpeechControls() {
    return Row(
      children: [
        const Icon(Icons.mic, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          'Voice Input',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: widget.enabled ? _toggleListening : null,
          icon: Icon(
            _isListening ? Icons.stop : Icons.mic,
            size: 18,
            color: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
          ),
          tooltip: _isListening ? 'Stop listening' : (widget.speechTooltip ?? 'Start voice input'),
          style: IconButton.styleFrom(
            backgroundColor: _isListening 
                ? Colors.red.withOpacity(0.1)
                : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            minimumSize: const Size(40, 32),
          ),
        ),
      ],
    );
  }


  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (kIsWeb) {
      // Use web speech service
      final webService = WebSpeechService();
      final initialized = await webService.initialize();
      
      if (!initialized) {
        _showWebLimitationMessage();
        return;
      }

      setState(() {
        _isListening = true;
      });

      await webService.startListening(
        onResult: _handleSpeechResult,
        onError: _handleSpeechError,
        localeId: widget.localeId,
      );
    } else {
      // Use mobile speech service
      final mobileService = SpeechToTextService();
      final initialized = await mobileService.initialize();
      
      if (!initialized) {
        _showError('Speech recognition not available');
        return;
      }

      setState(() {
        _isListening = true;
      });

      await mobileService.startListening(
        onResult: _handleSpeechResult,
        onError: _handleSpeechError,
        localeId: widget.localeId,
      );
    }
  }

  Future<void> _stopListening() async {
    if (kIsWeb) {
      final webService = WebSpeechService();
      await webService.stopListening();
    } else {
      final mobileService = SpeechToTextService();
      await mobileService.stopListening();
    }
    
    setState(() {
      _isListening = false;
    });
  }

  void _handleSpeechResult(String text) {
    if (mounted) {
      setState(() {
        _currentSpeechText = text;
      });
      
      // Append to existing text or replace if empty
      final currentText = widget.controller.text;
      final newText = currentText.isEmpty 
          ? text 
          : '$currentText $text';
      
      widget.controller.text = newText;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
      
      widget.onChanged?.call(newText);
    }
  }

  void _handleSpeechError(String error) {
    if (mounted) {
      setState(() {
        _isListening = false;
      });
      
      if (kIsWeb) {
        _showWebLimitationMessage();
      } else {
        _showError(error);
      }
    }
  }

  void _showWebLimitationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input is not yet available in web browsers. Please use the mobile app for speech-to-text functionality.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Speech recognition error: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// A specialized universal speech text field for journaling
class UniversalSpeechJournalField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Function(String)? onChanged;
  final String localeId;
  final bool showSpeechButton;
  final int? maxLines;

  const UniversalSpeechJournalField({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.localeId = 'en_US',
    this.showSpeechButton = true,
    this.maxLines = 6,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalSpeechTextField(
      controller: controller,
      hintText: hintText ?? 'Start typing or use voice input...',
      maxLines: maxLines,
      onChanged: onChanged,
      showSpeechButton: showSpeechButton,
      localeId: localeId,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

/// A mixin that can be added to any existing text field to add speech functionality
mixin SpeechToTextMixin<T extends StatefulWidget> on State<T> {
  bool _isListening = false;
  String _currentSpeechText = '';

  bool get isListening => _isListening;
  String get currentSpeechText => _currentSpeechText;

  Future<void> startSpeechToText({
    required TextEditingController controller,
    required Function(String)? onChanged,
    String localeId = 'en_US',
  }) async {
    if (kIsWeb) {
      final webService = WebSpeechService();
      final initialized = await webService.initialize();
      
      if (!initialized) {
        _showWebLimitationMessage();
        return;
      }

      setState(() {
        _isListening = true;
      });

      await webService.startListening(
        onResult: (text) => _handleSpeechResult(text, controller, onChanged),
        onError: _handleSpeechError,
        localeId: localeId,
      );
    } else {
      final mobileService = SpeechToTextService();
      final initialized = await mobileService.initialize();
      
      if (!initialized) {
        _showError('Speech recognition not available');
        return;
      }

      setState(() {
        _isListening = true;
      });

      await mobileService.startListening(
        onResult: (text) => _handleSpeechResult(text, controller, onChanged),
        onError: _handleSpeechError,
        localeId: localeId,
      );
    }
  }

  Future<void> stopSpeechToText() async {
    if (kIsWeb) {
      final webService = WebSpeechService();
      await webService.stopListening();
    } else {
      final mobileService = SpeechToTextService();
      await mobileService.stopListening();
    }
    
    setState(() {
      _isListening = false;
    });
  }

  void _handleSpeechResult(String text, TextEditingController controller, Function(String)? onChanged) {
    if (mounted) {
      setState(() {
        _currentSpeechText = text;
      });
      
      final currentText = controller.text;
      final newText = currentText.isEmpty ? text : '$currentText $text';
      
      controller.text = newText;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
      
      onChanged?.call(newText);
    }
  }

  void _handleSpeechError(String error) {
    if (mounted) {
      setState(() {
        _isListening = false;
      });
      
      if (kIsWeb) {
        _showWebLimitationMessage();
      } else {
        _showError(error);
      }
    }
  }

  void _showWebLimitationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input is not yet available in web browsers. Please use the mobile app for speech-to-text functionality.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Speech recognition error: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
