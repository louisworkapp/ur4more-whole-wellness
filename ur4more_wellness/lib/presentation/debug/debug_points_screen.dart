import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/state/points_store.dart';
import '../../design/tokens.dart';

class DebugPointsScreen extends StatefulWidget {
  const DebugPointsScreen({super.key});

  @override
  State<DebugPointsScreen> createState() => _DebugPointsScreenState();
}

class _DebugPointsScreenState extends State<DebugPointsScreen> {
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
    try {
      _userId = await AuthService.getCurrentUserId();
      if (_userId == null && kDebugMode) {
        // Use stable debug user ID
        _userId = "debug_user";
        await AuthService.saveAuthData(
          token: 'debug_token',
          userId: _userId!,
          expiryDate: DateTime.now().add(const Duration(days: 365)),
        );
        debugPrint('DebugPointsScreen: Created debug user: $_userId');
      }
      
      // Always reload to ensure we have latest data
      if (_userId != null) {
        await _store.load(_userId!);
        debugPrint('DebugPointsScreen: Loaded points for userId: $_userId');
      } else {
        debugPrint('DebugPointsScreen: No userId available');
      }
    } catch (e) {
      debugPrint('DebugPointsScreen: Error loading userId: $e');
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _awardPoints(String category, int delta) async {
    if (_userId == null) {
      debugPrint('DebugPointsScreen: No userId available');
      return;
    }

    setState(() => _isLoading = true);

    await _store.awardCategory(
      userId: _userId!,
      category: category,
      delta: delta,
      action: 'debug_adjust',
      note: 'manual test',
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reloadFromDisk() async {
    if (_userId == null) {
      debugPrint('DebugPointsScreen: No userId available');
      return;
    }

    setState(() => _isLoading = true);

    await _store.load(_userId!);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Points Store'),
        backgroundColor: cs.surfaceContainerHighest,
      ),
      body: _userId == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: Pad.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current Values Section
                  Card(
                    child: Padding(
                      padding: Pad.card,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Values',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpace.x3),
                          _buildValueRow('Total Points', _store.totalPoints.toString()),
                          const SizedBox(height: AppSpace.x2),
                          _buildValueRow('Body Points', '${_store.bodyPoints} (${(_store.bodyProgress * 100).toStringAsFixed(1)}%)'),
                          const SizedBox(height: AppSpace.x2),
                          _buildValueRow('Mind Points', '${_store.mindPoints} (${(_store.mindProgress * 100).toStringAsFixed(1)}%)'),
                          const SizedBox(height: AppSpace.x2),
                          _buildValueRow('Spirit Points', '${_store.spiritPoints} (${(_store.spiritProgress * 100).toStringAsFixed(1)}%)'),
                          const SizedBox(height: AppSpace.x2),
                          _buildValueRow('User ID', _userId ?? 'N/A'),
                          const SizedBox(height: AppSpace.x2),
                          _buildValueRow('Loaded', _store.loaded ? 'Yes' : 'No'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpace.x4),

                  // Award Points Section
                  Text(
                    'Award Points',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpace.x2),

                  // Body buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _awardPoints('body', 10),
                          icon: const Icon(Icons.add),
                          label: const Text('+10 Body'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpace.x2),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _awardPoints('body', -10),
                          icon: const Icon(Icons.remove),
                          label: const Text('-10 Body'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpace.x2),

                  // Mind buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _awardPoints('mind', 10),
                          icon: const Icon(Icons.add),
                          label: const Text('+10 Mind'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpace.x2),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _awardPoints('mind', -10),
                          icon: const Icon(Icons.remove),
                          label: const Text('-10 Mind'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpace.x2),

                  // Spirit buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _awardPoints('spirit', 10),
                          icon: const Icon(Icons.add),
                          label: const Text('+10 Spirit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpace.x2),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _awardPoints('spirit', -10),
                          icon: const Icon(Icons.remove),
                          label: const Text('-10 Spirit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade900,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpace.x4),

                  // Reload button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _reloadFromDisk,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text('Reload from disk'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpace.x3),
                    ),
                  ),

                  const SizedBox(height: AppSpace.x4),

                  // Info section
                  Card(
                    color: cs.surfaceContainerHighest,
                    child: Padding(
                      padding: Pad.card,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug Info',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpace.x2),
                          Text(
                            '• Changes are persisted to SharedPreferences\n'
                            '• Check console for debug logs\n'
                            '• Return to Home to see animations\n'
                            '• Values persist after app restart',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
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
}

