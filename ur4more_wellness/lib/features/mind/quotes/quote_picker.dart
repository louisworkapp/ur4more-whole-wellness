import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class QuoteItem {
  final String id, text, author;
  final List<String> tags;
  
  QuoteItem({
    required this.id, 
    required this.text, 
    required this.author, 
    required this.tags,
  });
}

class QuoteLibrary {
  final List<QuoteItem> items;
  
  QuoteLibrary(this.items);

  static Future<QuoteLibrary> load() async {
    final raw = await rootBundle.loadString('assets/mind/quotes/quotes.json');
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    return QuoteLibrary(list.map((m) => QuoteItem(
      id: m['id'],
      text: m['text'],
      author: m['author'] ?? '',
      tags: ((m['tags'] ?? []) as List).cast<String>(),
    )).toList());
  }

  List<QuoteItem> filtered({
    required bool allowFaith, 
    required bool allowSecular, 
    String q = '',
  }) {
    return items.where((it) {
      final isFaith = it.tags.contains('faith');
      final isSec = it.tags.contains('secular');
      if (isFaith && !allowFaith) return false;
      if (isSec && !allowSecular) return false;
      if (q.isNotEmpty && !('${it.text} ${it.author}'.toLowerCase()).contains(q.toLowerCase())) return false;
      return true;
    }).toList();
  }
}

Future<QuoteItem?> showQuotePicker({
  required BuildContext context,
  required bool faithActivated,
  required bool hideFaithOverlaysInMind,
  required bool lightConsentGiven, // for Light mode per-session
}) async {
  final lib = await QuoteLibrary.load();

  final allowFaith = faithActivated && !hideFaithOverlaysInMind && lightConsentGiven;
  final allowSecular = true; // always fine

  bool faithOnly = allowFaith; // start ON if allowed
  String search = '';
  QuoteItem? selection;

  return showDialog<QuoteItem?>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setState) {
        final list = lib.filtered(
          allowFaith: allowFaith && (faithOnly ? true : true),
          allowSecular: faithOnly ? false : allowSecular,
          q: search,
        );
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Expanded(child: Text('Pick a quote', style: Theme.of(context).textTheme.titleMedium)),
                    TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('None')),
                  ]),
                  const SizedBox(height: 8),
                  if (allowFaith) SwitchListTile(
                    value: faithOnly,
                    onChanged: (v) => setState(() => faithOnly = v),
                    title: const Text('Faith quotes only'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  TextField(
                    onChanged: (v) => setState(() => search = v),
                    decoration: const InputDecoration(
                      hintText: 'Search quotes or authors',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: list.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('No quotes match.'),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final q = list[i];
                            return ListTile(
                              title: Text(q.text, maxLines: 3, overflow: TextOverflow.ellipsis),
                              subtitle: Text(q.author.isEmpty ? '—' : q.author),
                              onTap: () { selection = q; Navigator.pop(ctx, selection); },
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}
