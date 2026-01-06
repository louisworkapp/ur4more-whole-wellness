import 'package:flutter/material.dart';

/// Web stub for speech-to-text. Returns false/not available and no-ops.
class SpeechToTextService {
  static final SpeechToTextService _instance = SpeechToTextService._internal();
  factory SpeechToTextService() => _instance;
  SpeechToTextService._internal();

  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';

  Future<bool> initialize() async {
    _isInitialized = false;
    return false;
  }

  bool get isAvailable => false;
  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
    String localeId = 'en_US',
  }) async {
    onError?.call('Speech recognition not available on web');
  }

  Future<void> stopListening() async {
    _isListening = false;
  }

  Future<void> cancelListening() async {
    _isListening = false;
  }

  Future<List<dynamic>> getAvailableLocales() async => [];
  Future<bool> isLocaleAvailable(String localeId) async => false;
  void dispose() {
    _isInitialized = false;
    _isListening = false;
  }
}

class SpeechToTextWidget extends StatelessWidget {
  final Function(String) onResult;
  final Function(String)? onError;
  final Widget child;
  final String localeId;
  final bool autoStart;
  final Duration? listenDuration;

  const SpeechToTextWidget({
    super.key,
    required this.onResult,
    required this.child,
    this.onError,
    this.localeId = 'en_US',
    this.autoStart = false,
    this.listenDuration,
  });

  @override
  Widget build(BuildContext context) => child;
}

class SpeechToTextButton extends StatelessWidget {
  final Function(String) onResult;
  final Function(String)? onError;
  final String localeId;
  final IconData? icon;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;

  const SpeechToTextButton({
    super.key,
    required this.onResult,
    this.onError,
    this.localeId = 'en_US',
    this.icon,
    this.tooltip,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onError?.call('Speech recognition not available on web'),
      icon: Icon(icon ?? Icons.mic_off, color: color ?? Theme.of(context).colorScheme.onSurfaceVariant),
      tooltip: tooltip ?? 'Voice not available on web',
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surfaceVariant,
      ),
    );
  }
}

