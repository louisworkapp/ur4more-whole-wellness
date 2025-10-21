import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebSpeechService {
  static final WebSpeechService _instance = WebSpeechService._internal();
  factory WebSpeechService() => _instance;
  WebSpeechService._internal();

  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';

  /// Check if speech recognition is available in the browser
  bool get isAvailable => false; // Simplified for now

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Get the last recognized words
  String get lastWords => _lastWords;

  /// Initialize the speech recognition service
  Future<bool> initialize() async {
    if (!kIsWeb) return false;
    
    // For now, we'll return false to indicate web speech is not available
    // This can be enhanced later with proper Web Speech API implementation
    _isInitialized = false;
    return false;
  }

  /// Start listening for speech
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
    String localeId = 'en-US',
  }) async {
    onError?.call('Speech-to-text is not yet available in web browsers. Please use the mobile app for voice input.');
  }

  /// Stop listening
  Future<void> stopListening() async {
    _isListening = false;
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    _isListening = false;
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    return false;
  }

  /// Dispose resources
  void dispose() {
    _isListening = false;
  }
}

/// A web-compatible speech-to-text widget that shows a helpful message
class WebSpeechTextField extends StatefulWidget {
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

  const WebSpeechTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.localeId = 'en-US',
    this.showSpeechButton = true,
    this.speechIcon,
    this.speechTooltip,
  });

  @override
  State<WebSpeechTextField> createState() => _WebSpeechTextFieldState();
}

class _WebSpeechTextFieldState extends State<WebSpeechTextField> {
  final WebSpeechService _speechService = WebSpeechService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    if (kIsWeb) {
      final initialized = await _speechService.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = initialized;
        });
      }
    }
  }

  void _showWebLimitationMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input is not yet available in web browsers. Please use the mobile app for speech-to-text functionality.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }

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
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            suffixIcon: widget.showSpeechButton && kIsWeb ? _buildSpeechButton() : null,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        
        // Web limitation notice
        if (kIsWeb && widget.showSpeechButton)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Voice input available in mobile app',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget? _buildSpeechButton() {
    if (!kIsWeb) return null;
    
    return IconButton(
      onPressed: _showWebLimitationMessage,
      icon: Icon(
        widget.speechIcon ?? Icons.mic_none,
        color: Colors.orange,
      ),
      tooltip: 'Voice input not available in web browsers',
      style: IconButton.styleFrom(
        backgroundColor: Colors.orange.withOpacity(0.1),
      ),
    );
  }
}