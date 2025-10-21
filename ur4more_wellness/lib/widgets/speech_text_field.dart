import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/speech_to_text_service.dart';
import 'universal_speech_text_field.dart';

/// Legacy SpeechTextField - now uses UniversalSpeechTextField
class SpeechTextField extends StatelessWidget {
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

  const SpeechTextField({
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
  });

  @override
  Widget build(BuildContext context) {
    return UniversalSpeechTextField(
      controller: controller,
      hintText: hintText,
      labelText: labelText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      localeId: localeId,
      showSpeechButton: showSpeechButton,
      speechIcon: speechIcon,
      speechTooltip: speechTooltip,
    );
  }
}


/// A specialized speech-enabled text field for journaling
class SpeechJournalField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Function(String)? onChanged;
  final String localeId;
  final bool showSpeechButton;

  const SpeechJournalField({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.localeId = 'en_US',
    this.showSpeechButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalSpeechJournalField(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      localeId: localeId,
      showSpeechButton: showSpeechButton,
    );
  }
}

