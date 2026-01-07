import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/points_service.dart';

class PointsStore extends ChangeNotifier {
  static final PointsStore _instance = PointsStore._internal();
  factory PointsStore() => _instance;
  PointsStore._internal();

  static PointsStore get i => _instance;

  // Goals
  static const int bodyGoal = 2000;
  static const int mindGoal = 2000;
  static const int spiritGoal = 2000;

  // State
  int _totalPoints = 0;
  int _bodyPoints = 0;
  int _mindPoints = 0;
  int _spiritPoints = 0;

  // Getters
  int get totalPoints => _totalPoints;
  int get bodyPoints => _bodyPoints;
  int get mindPoints => _mindPoints;
  int get spiritPoints => _spiritPoints;

  double get bodyProgress => (_bodyPoints / bodyGoal).clamp(0.0, 1.0);
  double get mindProgress => (_mindPoints / mindGoal).clamp(0.0, 1.0);
  double get spiritProgress => (_spiritPoints / spiritGoal).clamp(0.0, 1.0);

  bool _loaded = false;
  String? _currentUserId;
  bool get loaded => _loaded;

  /// Load points from persistence
  Future<void> load(String userId) async {
    // Only skip if already loaded for the same user
    if (_loaded && _currentUserId == userId) return;

    debugPrint('PointsStore.load: Loading points for userId=$userId');

    try {
      final prefs = await SharedPreferences.getInstance();
      
      final beforeTotal = _totalPoints;
      final beforeBody = _bodyPoints;
      final beforeMind = _mindPoints;
      final beforeSpirit = _spiritPoints;

      _totalPoints = prefs.getInt('points_total_$userId') ?? 0;
      _bodyPoints = prefs.getInt('points_body_$userId') ?? 0;
      _mindPoints = prefs.getInt('points_mind_$userId') ?? 0;
      _spiritPoints = prefs.getInt('points_spirit_$userId') ?? 0;

      debugPrint('PointsStore.load: Before -> Total=$beforeTotal, Body=$beforeBody, Mind=$beforeMind, Spirit=$beforeSpirit');
      debugPrint('PointsStore.load: After  -> Total=$_totalPoints, Body=$_bodyPoints, Mind=$_mindPoints, Spirit=$_spiritPoints');

      _currentUserId = userId;
      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('PointsStore.load: Error loading points: $e');
      _loaded = true; // Mark as loaded even on error to prevent retry loops
    }
  }

  /// Award points to a specific category
  Future<void> awardCategory({
    required String userId,
    required String category,
    required int delta,
    required String action,
    String? note,
  }) async {
    // Validate category
    if (!['body', 'mind', 'spirit'].contains(category.toLowerCase())) {
      debugPrint('PointsStore.awardCategory: Invalid category: $category');
      return;
    }

    final beforeTotal = _totalPoints;
    final beforeBody = _bodyPoints;
    final beforeMind = _mindPoints;
    final beforeSpirit = _spiritPoints;

    debugPrint('PointsStore.awardCategory: userId=$userId, category=$category, delta=$delta, action=$action');
    debugPrint('PointsStore.awardCategory: Before -> Total=$beforeTotal, Body=$beforeBody, Mind=$beforeMind, Spirit=$beforeSpirit');

    try {
      // Call PointsService to log the action
      await PointsService.award(
        userId: userId,
        action: action,
        value: delta,
        note: note,
      );

      // Update local state
      _totalPoints = (_totalPoints + delta).clamp(0, double.infinity).toInt();

      switch (category.toLowerCase()) {
        case 'body':
          _bodyPoints = (_bodyPoints + delta).clamp(0, double.infinity).toInt();
          break;
        case 'mind':
          _mindPoints = (_mindPoints + delta).clamp(0, double.infinity).toInt();
          break;
        case 'spirit':
          _spiritPoints = (_spiritPoints + delta).clamp(0, double.infinity).toInt();
          break;
      }

      debugPrint('PointsStore.awardCategory: After  -> Total=$_totalPoints, Body=$_bodyPoints, Mind=$_mindPoints, Spirit=$_spiritPoints');

      // Persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('points_total_$userId', _totalPoints);
      await prefs.setInt('points_body_$userId', _bodyPoints);
      await prefs.setInt('points_mind_$userId', _mindPoints);
      await prefs.setInt('points_spirit_$userId', _spiritPoints);

      notifyListeners();
    } catch (e) {
      debugPrint('PointsStore.awardCategory: Error awarding points: $e');
    }
  }

  /// Reset store (for testing/logout)
  Future<void> reset(String userId) async {
    _totalPoints = 0;
    _bodyPoints = 0;
    _mindPoints = 0;
    _spiritPoints = 0;
    _loaded = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('points_total_$userId');
      await prefs.remove('points_body_$userId');
      await prefs.remove('points_mind_$userId');
      await prefs.remove('points_spirit_$userId');
    } catch (e) {
      debugPrint('Error resetting points: $e');
    }

    notifyListeners();
  }
}

