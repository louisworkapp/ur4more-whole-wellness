import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextService {
  static final SpeechToTextService _instance = SpeechToTextService._internal();
  factory SpeechToTextService() => _instance;
  SpeechToTextService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';

  /// Initialize the speech-to-text service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Check and request microphone permission
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        return false;
      }

      // Initialize speech recognition
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          _isListening = status == 'listening';
        },
        onError: (error) {
          debugPrint('Speech recognition error: $error');
        },
      );

      return _isInitialized;
    } catch (e) {
      debugPrint('Failed to initialize speech-to-text: $e');
      return false;
    }
  }

  /// Check if speech recognition is available
  bool get isAvailable => _isInitialized && _speech.isAvailable;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Get the last recognized words
  String get lastWords => _lastWords;

  /// Start listening for speech
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
    String localeId = 'en_US',
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call('Speech recognition not available');
        return;
      }
    }

    if (!_speech.isAvailable) {
      onError?.call('Speech recognition not available on this device');
      return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          onResult(result.recognizedWords);
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (e) {
      onError?.call('Failed to start listening: $e');
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
    }
  }

  /// Get available locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _speech.locales();
  }

  /// Check if a specific locale is available
  Future<bool> isLocaleAvailable(String localeId) async {
    final locales = await getAvailableLocales();
    return locales.any((locale) => locale.localeId == localeId);
  }

  /// Dispose resources
  void dispose() {
    _speech.stop();
    _isInitialized = false;
    _isListening = false;
  }
}

/// A widget that provides speech-to-text functionality
class SpeechToTextWidget extends StatefulWidget {
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
  State<SpeechToTextWidget> createState() => _SpeechToTextWidgetState();
}

class _SpeechToTextWidgetState extends State<SpeechToTextWidget> {
  final SpeechToTextService _speechService = SpeechToTextService();
  bool _isInitialized = false;
  bool _isListening = false;
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final initialized = await _speechService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = initialized;
      });
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized) return;

    setState(() {
      _isListening = true;
      _currentText = '';
    });

    await _speechService.startListening(
      onResult: (text) {
        if (mounted) {
          setState(() {
            _currentText = text;
          });
          widget.onResult(text);
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
          widget.onError?.call(error);
        }
      },
      localeId: widget.localeId,
    );
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  /// Public methods to control speech recognition
  void startListening() => _startListening();
  void stopListening() => _stopListening();
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  String get currentText => _currentText;
}

/// A simple speech-to-text button widget
class SpeechToTextButton extends StatefulWidget {
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
  State<SpeechToTextButton> createState() => _SpeechToTextButtonState();
}

class _SpeechToTextButtonState extends State<SpeechToTextButton> {
  final SpeechToTextService _speechService = SpeechToTextService();
  bool _isInitialized = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final initialized = await _speechService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = initialized;
      });
    }
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) {
      widget.onError?.call('Speech recognition not available');
      return;
    }

    if (_isListening) {
      await _speechService.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _isListening = true;
      });

      await _speechService.startListening(
        onResult: (text) {
          widget.onResult(text);
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
            widget.onError?.call(error);
          }
        },
        localeId: widget.localeId,
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
    return IconButton(
      onPressed: _isInitialized ? _toggleListening : null,
      icon: Icon(
        _isListening ? Icons.mic : (widget.icon ?? Icons.mic_none),
        color: _isListening
            ? Colors.red
            : (widget.color ?? Theme.of(context).colorScheme.primary),
      ),
      tooltip: widget.tooltip ?? (_isListening ? 'Stop listening' : 'Start voice input'),
      style: IconButton.styleFrom(
        backgroundColor: _isListening
            ? Colors.red.withOpacity(0.1)
            : (widget.backgroundColor ?? Theme.of(context).colorScheme.primaryContainer),
      ),
    );
  }
}

