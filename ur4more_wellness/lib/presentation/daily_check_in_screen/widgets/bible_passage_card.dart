import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../features/mind/urge/models/urge_theme_model.dart';
import '../../../services/faith_service.dart';

class BiblePassageCard extends StatefulWidget {
  final BiblePassage passage;
  final FaithTier faithMode;
  final bool hideFaithOverlaysInMind;

  const BiblePassageCard({
    super.key,
    required this.passage,
    required this.faithMode,
    this.hideFaithOverlaysInMind = false,
  });

  @override
  State<BiblePassageCard> createState() => _BiblePassageCardState();
}

class _BiblePassageCardState extends State<BiblePassageCard> {
  int _currentVerseIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Check if faith content should be shown
    final shouldShowFaith = widget.faithMode.isActivated && !widget.hideFaithOverlaysInMind;
    
    if (!shouldShowFaith || widget.passage.verses.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentVerse = widget.passage.verses[_currentVerseIndex];
    final hasMultipleVerses = widget.passage.verses.length > 1;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with reference and navigation
          Row(
            children: [
              Icon(
                Icons.menu_book,
                color: colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.passage.ref,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
              if (hasMultipleVerses) ...[
                IconButton(
                  onPressed: _currentVerseIndex > 0 ? _previousVerse : null,
                  icon: Icon(
                    Icons.chevron_left,
                    color: _currentVerseIndex > 0 
                        ? colorScheme.secondary 
                        : colorScheme.outline,
                  ),
                ),
                Text(
                  '${_currentVerseIndex + 1}/${widget.passage.verses.length}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                IconButton(
                  onPressed: _currentVerseIndex < widget.passage.verses.length - 1 
                      ? _nextVerse 
                      : null,
                  icon: Icon(
                    Icons.chevron_right,
                    color: _currentVerseIndex < widget.passage.verses.length - 1 
                        ? colorScheme.secondary 
                        : colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Verse text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verse number
                Text(
                  '${currentVerse.v}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                // Verse text
                Text(
                  currentVerse.t,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action prompt
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: colorScheme.secondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.passage.actNow,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextVerse() {
    if (_currentVerseIndex < widget.passage.verses.length - 1) {
      setState(() {
        _currentVerseIndex++;
      });
    }
  }

  void _previousVerse() {
    if (_currentVerseIndex > 0) {
      setState(() {
        _currentVerseIndex--;
      });
    }
  }
}
