import 'package:flutter/material.dart';
import '../../mind/quotes/quote_picker.dart';

/// Inline quote rotator with Next/None buttons and AnimatedSwitcher
/// 
/// Features:
/// - Faith-aware quote filtering
/// - Smooth AnimatedSwitcher transitions
/// - Next/None button controls
/// - Analytics tracking for quote interactions
class QuoteRotator extends StatefulWidget {
  final bool faithActivated;
  final bool hideFaithOverlaysInMind;
  final bool lightConsentGiven;
  final Function(String event, Map<String, dynamic> props)? onAnalytics;

  const QuoteRotator({
    super.key,
    required this.faithActivated,
    required this.hideFaithOverlaysInMind,
    required this.lightConsentGiven,
    this.onAnalytics,
  });

  @override
  State<QuoteRotator> createState() => _QuoteRotatorState();
}

class _QuoteRotatorState extends State<QuoteRotator> {
  List<QuoteItem> _pool = [];
  int _index = -1; // -1 = None
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    try {
      final lib = await QuoteLibrary.load();
      
      // Determine what quotes are allowed
      final allowFaith = widget.faithActivated && 
                        !widget.hideFaithOverlaysInMind && 
                        widget.lightConsentGiven;
      final allowSecular = true; // Always allow secular quotes
      
      // Filter quotes based on permissions
      _pool = lib.filtered(
        allowFaith: allowFaith,
        allowSecular: allowSecular,
      );
      
      // Set initial quote if pool is not empty
      if (_pool.isNotEmpty) {
        _index = 0;
      }
      
      setState(() {
        _isLoading = false;
      });
      
      // Track analytics
      _trackAnalytics('quote_pool_loaded', {
        'pool_size': _pool.length,
        'pool_type': allowFaith ? 'faith+secular' : 'secular',
        'allow_faith': allowFaith,
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _trackAnalytics('quote_load_error', {'error': e.toString()});
    }
  }

  void _nextQuote() {
    if (_pool.isEmpty) return;
    
    setState(() {
      _index = (_index + 1) % _pool.length;
    });
    
    _trackAnalytics('quote_next', {
      'quote_id': _pool[_index].id,
      'pool_type': widget.faithActivated ? 'faith+secular' : 'secular',
    });
  }

  void _hideQuote() {
    setState(() {
      _index = -1;
    });
    
    _trackAnalytics('quote_none', {
      'pool_type': widget.faithActivated ? 'faith+secular' : 'secular',
    });
  }

  void _trackAnalytics(String event, Map<String, dynamic> props) {
    widget.onAnalytics?.call(event, props);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_isLoading) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final showQuote = _index >= 0 && _index < _pool.length;
    final currentQuote = showQuote ? _pool[_index] : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Control buttons
        Row(
          children: [
            if (showQuote)
              TextButton(
                onPressed: _hideQuote,
                child: const Text('None'),
              ),
            if (_pool.isNotEmpty)
              TextButton(
                onPressed: _nextQuote,
                child: const Text('Next'),
              ),
            const Spacer(),
            if (_pool.isNotEmpty)
              Text(
                '${_index + 1}/${_pool.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        
        // Quote display with AnimatedSwitcher
        if (showQuote && currentQuote != null)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  )),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey(currentQuote.id),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quote text
                  Text(
                    '"${currentQuote.text}"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Author
                  Row(
                    children: [
                      const Text('— '),
                      Expanded(
                        child: Text(
                          currentQuote.author,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  // Tags (if any)
                  if (currentQuote.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: currentQuote.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          )
        else if (_pool.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Text(
              'No quotes available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
