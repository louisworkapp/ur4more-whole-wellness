import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/state/points_store.dart';
import '../../design/tokens.dart';

class DebugPointsBottomSheet extends StatefulWidget {
  const DebugPointsBottomSheet({super.key});

  static void show(BuildContext context) {
    if (!kDebugMode) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DebugPointsBottomSheet(),
    );
  }

  @override
  State<DebugPointsBottomSheet> createState() => _DebugPointsBottomSheetState();
}

class _DebugPointsBottomSheetState extends State<DebugPointsBottomSheet> {
  final PointsStore _store = PointsStore.i;
  String? _userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadUserId() async {
    _userId = await AuthService.getCurrentUserId();
    if (_userId == null && kDebugMode) {
      // Create a test user if none exists
      _userId = "debug_user_${DateTime.now().millisecondsSinceEpoch}";
      await AuthService.saveAuthData(
        token: 'debug_token',
        userId: _userId!,
        expiryDate: DateTime.now().add(const Duration(days: 365)),
      );
    }
    if (_userId != null) {
      // Always reload to ensure we have latest data
      await _store.load(_userId!);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _awardPoints(String category, int delta) async {
    if (_userId == null) return;

    setState(() => _isLoading = true);
    await _store.awardCategory(
      userId: _userId!,
      category: category,
      delta: delta,
      action: 'debug_test',
      note: 'quick test',
    );
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpace.x2),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: Pad.card,
              child: Row(
                children: [
                  Icon(Icons.bug_report, color: cs.primary),
                  const SizedBox(width: AppSpace.x2),
                  Text(
                    'Test Points',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Current Values
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
              child: Container(
                padding: Pad.card,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildValueRow('Total', _store.totalPoints.toString()),
                    const Divider(height: AppSpace.x3),
                    _buildValueRow('Body', '${_store.bodyPoints} (${(_store.bodyProgress * 100).toStringAsFixed(0)}%)'),
                    _buildValueRow('Mind', '${_store.mindPoints} (${(_store.mindProgress * 100).toStringAsFixed(0)}%)'),
                    _buildValueRow('Spirit', '${_store.spiritPoints} (${(_store.spiritProgress * 100).toStringAsFixed(0)}%)'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpace.x3),

            // Test Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTestButton(
                          '+10 Body',
                          Colors.blue,
                          () => _awardPoints('body', 10),
                        ),
                      ),
                      const SizedBox(width: AppSpace.x2),
                      Expanded(
                        child: _buildTestButton(
                          '-10 Body',
                          Colors.blue.shade700,
                          () => _awardPoints('body', -10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.x2),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTestButton(
                          '+10 Mind',
                          Colors.teal,
                          () => _awardPoints('mind', 10),
                        ),
                      ),
                      const SizedBox(width: AppSpace.x2),
                      Expanded(
                        child: _buildTestButton(
                          '-10 Mind',
                          Colors.teal.shade700,
                          () => _awardPoints('mind', -10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.x2),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTestButton(
                          '+10 Spirit',
                          Colors.amber.shade700,
                          () => _awardPoints('spirit', 10),
                        ),
                      ),
                      const SizedBox(width: AppSpace.x2),
                      Expanded(
                        child: _buildTestButton(
                          '-10 Spirit',
                          Colors.amber.shade900,
                          () => _awardPoints('spirit', -10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpace.x4),
          ],
        ),
      ),
    );
  }

  Widget _buildValueRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildTestButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppSpace.x2),
      ),
      child: Text(label),
    );
  }
}

