import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../courses/models/course.dart';
import '../../../routes/app_routes.dart';
import '../../../services/faith_service.dart';

class DiscipleshipHeader extends StatefulWidget {
  const DiscipleshipHeader({super.key});

  @override
  State<DiscipleshipHeader> createState() => _DiscipleshipHeaderState();
}

class _DiscipleshipHeaderState extends State<DiscipleshipHeader> {
  double _progress = 0.0; // 0..1
  int _week = 0;
  bool _hasStarted = false;
  FaithTier _tier = FaithTier.off;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _loadFaithTier();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final pct = prefs.getDouble('course:${AppRoutes.ur4moreCoreId}:progress') ?? 0;
    final w = prefs.getInt('course:${AppRoutes.ur4moreCoreId}:week') ?? 0;
    setState(() {
      _progress = pct.clamp(0, 1);
      _week = w;
      _hasStarted = _progress > 0;
    });
  }

  Future<void> _loadFaithTier() async {
    final faithMode = await FaithService.getFaithMode();
    setState(() {
      _tier = _getFaithTierFromMode(faithMode.toString().split('.').last);
    });
  }

  FaithTier _getFaithTierFromMode(String faithMode) {
    switch (faithMode.toLowerCase()) {
      case 'off':
        return FaithTier.off;
      case 'light':
        return FaithTier.light;
      case 'disciple':
        return FaithTier.disciple;
      case 'kingdom':
        return FaithTier.kingdomBuilder;
      default:
        return FaithTier.off;
    }
  }

  void _goStartOrContinue() {
    if (_hasStarted) {
      Navigator.pushNamed(
        context,
        AppRoutes.courseDetail,
        arguments: {'courseId': AppRoutes.ur4moreCoreId},
      );
    } else {
      // For Light tier you might prefer courses list:
      final goCore = _tier == FaithTier.disciple || _tier == FaithTier.kingdomBuilder;
      if (goCore) {
        Navigator.pushNamed(
          context,
          AppRoutes.courseDetail,
          arguments: {'courseId': AppRoutes.ur4moreCoreId},
        );
      } else {
        Navigator.pushNamed(context, AppRoutes.discipleshipCourses);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tier == FaithTier.off) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(.14),
            cs.primary.withOpacity(.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withOpacity(.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header icon + title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.auto_stories_rounded, color: cs.onPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Start your Discipleship',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
              ),
              if (_hasStarted)
                _ProgressChip(progress: _progress, week: _week),
            ],
          ),
          const SizedBox(height: 8),

          // supportive copy
          Text(
            _tier == FaithTier.light
                ? 'Explore Alpha and our Core track—gentle, practical steps to grow spiritually.'
                : 'A 12-week journey to follow Jesus deeply and multiply impact.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 12),

          // CTA row
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _goStartOrContinue,
                icon: Icon(_hasStarted ? Icons.play_arrow_rounded : Icons.flag),
                label: Text(_hasStarted ? 'Continue' : 'Start Discipleship'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.courses),
                child: const Text('Browse courses'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  final double progress;
  final int week;
  const _ProgressChip({required this.progress, required this.week});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Week $week • $pct%',
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
