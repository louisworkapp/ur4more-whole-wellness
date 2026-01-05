import 'package:flutter/material.dart';
import '../../../services/faith_service.dart';
import '../../../widgets/verse_reveal_chip.dart';
import '../../../services/gateway_service.dart';
import '../../../core/settings/settings_scope.dart';
import '../../../core/settings/settings_model.dart';
import '../../../theme/tokens.dart';

class DailyInspiration extends StatefulWidget {
  final FaithTier mode;
  final bool hideFaithOverlaysInMind;
  
  const DailyInspiration({
    super.key, 
    required this.mode, 
    required this.hideFaithOverlaysInMind,
  });

  @override
  State<DailyInspiration> createState() => _DailyInspirationState();
}

class _DailyInspirationState extends State<DailyInspiration> {
  List<Map<String, dynamic>> _quotes = [];
  int _currentQuoteIndex = 0;
  bool _isLoading = true;
  FaithTier? _lastFaithTier;

  @override
  void initState() {
    super.initState();
    // Don't load quotes in initState - wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if faith mode has changed
    final settingsCtl = SettingsScope.of(context);
    final currentFaithTier = settingsCtl.value.faithTier;
    
    if (_lastFaithTier != null && _lastFaithTier != currentFaithTier) {
      print('🔄 MindCoach DailyInspiration: Faith mode changed from $_lastFaithTier to $currentFaithTier');
      // Clear cache and reload quotes when faith mode changes
      _clearCacheAndReload();
    } else if (_quotes.isEmpty) {
      // Load quotes after dependencies are available (first time)
      _loadDailyQuotes();
    }
    
    _lastFaithTier = currentFaithTier;
  }

  Future<void> _clearCacheAndReload() async {
    // Clear the quote cache
    await GatewayService.clearQuoteCache();
    
    // Reset state
    setState(() {
      _quotes = [];
      _currentQuoteIndex = 0;
      _isLoading = true;
    });
    
    // Reload quotes with new faith mode
    await _loadDailyQuotes();
  }

  Future<void> _loadDailyQuotes() async {
    try {
      final settingsCtl = SettingsScope.of(context);
      final settings = settingsCtl.value;
      
      print('🎯 MindCoach DailyInspiration: Current faithTier: ${settings.faithTier}');
      
      final quotes = await GatewayService.fetchDailyQuotes(
        faithTier: settings.faithTier,
        topic: 'mind_coach',
        limit: 10,
      );
      
      if (mounted) {
        setState(() {
          _quotes = quotes;
          _isLoading = false;
          _currentQuoteIndex = 0;
        });
      }
    } catch (e) {
      print('Error loading mind coach daily quotes: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _refreshQuote() {
    if (_quotes.isNotEmpty) {
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final offMode = widget.mode.isOff;
    
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            const Text('Finding something good for today…'),
          ],
        ),
      );
    }

    if (_quotes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('No inspiration available right now.'),
      );
    }
    
    final quote = _quotes[_currentQuoteIndex];
    final isFaithQuote = quote['tags']?.contains('faith') ?? false;
    
    return GestureDetector(
      onTap: _refreshQuote,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFaithQuote 
              ? T.gold.withOpacity(0.3)  // Faith content: golden border
              : T.ink500.withOpacity(0.2), // Secular content: neutral border
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Daily Inspiration', 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // Show faith indicator
                if (isFaithQuote) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: T.gold.withOpacity(0.15), // Faith: golden background
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: T.gold, // Faith: golden icon
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Faith',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: T.gold, // Faith: golden text
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: T.ink500.withOpacity(0.15), // Secular: neutral background
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Wisdom',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: T.ink500, // Secular: neutral text
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Icon(
                  Icons.refresh,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '"${quote['text']}"', 
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 6),
            Text(
              '— ${quote['author']}', 
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Source: ${quote['source']} • Tap to refresh',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            // Show scripture if available and in faith mode
            if (!offMode && 
                !widget.hideFaithOverlaysInMind && 
                isFaithQuote &&
                quote['scripture_ref'] != null &&
                quote['scripture_ref'].isNotEmpty) ...[
              const SizedBox(height: 10),
              VerseRevealChip(
                mode: widget.mode,
                ref: quote['scripture_ref'],
                text: quote['scripture_text'] ?? '',
                askConsentLight: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
