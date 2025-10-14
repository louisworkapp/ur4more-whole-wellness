import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../design/tokens.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/coping_mechanism_tracker.dart';
import './widgets/journal_entry_interface.dart';
import './widgets/journal_timeline_card.dart';
import './widgets/mind_wellness_header.dart';
import './widgets/reflection_prompt_card.dart';

class MindWellnessScreen extends StatefulWidget {
  const MindWellnessScreen({super.key});

  @override
  State<MindWellnessScreen> createState() => _MindWellnessScreenState();
}

class _MindWellnessScreenState extends State<MindWellnessScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  int _currentPromptIndex = 0;
  String _currentJournalEntry = '';
  int _mentalWellnessPoints = 1250;
  int _reflectionStreak = 7;
  bool _isLoading = false;

  // Mock data for reflection prompts
  final List<Map<String, dynamic>> _reflectionPrompts = [
    {
      "id": "1",
      "category": "Gratitude",
      "question":
          "What are three things you're genuinely grateful for today, and how do they make you feel?",
      "estimatedTime": 5,
    },
    {
      "id": "2",
      "category": "Self-Reflection",
      "question":
          "What emotions have you experienced most strongly today? What might be behind these feelings?",
      "estimatedTime": 7,
    },
    {
      "id": "3",
      "category": "Growth",
      "question":
          "What's one challenge you're facing right now, and what strength within you can help you overcome it?",
      "estimatedTime": 8,
    },
    {
      "id": "4",
      "category": "Mindfulness",
      "question":
          "Take a moment to notice your surroundings. What do you see, hear, or feel that brings you peace?",
      "estimatedTime": 5,
    },
    {
      "id": "5",
      "category": "Purpose",
      "question":
          "How did you make a positive difference in someone's life today, no matter how small?",
      "estimatedTime": 6,
    },
  ];

  // Mock data for journal entries
  final List<Map<String, dynamic>> _journalEntries = [
    {
      "id": "1",
      "date": DateTime.now().subtract(const Duration(hours: 2)),
      "content":
          "Today I felt overwhelmed with work deadlines, but I took a few minutes to practice deep breathing. It really helped me center myself and approach my tasks with more clarity. I'm learning that taking breaks isn't selfish - it's necessary for my mental health.",
      "mood": "peaceful",
      "tags": ["work", "breathing", "self-care"],
      "isFavorite": true,
    },
    {
      "id": "2",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "content":
          "Had a wonderful conversation with my friend Sarah today. She reminded me that it's okay to not have everything figured out. Sometimes I put so much pressure on myself to be perfect, but life is about the journey, not the destination.",
      "mood": "grateful",
      "tags": ["friendship", "acceptance", "growth"],
      "isFavorite": false,
    },
    {
      "id": "3",
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "content":
          "Feeling anxious about the upcoming presentation at work. My mind keeps racing with 'what if' scenarios. I need to remember that I've prepared well and that anxiety is just my mind trying to protect me. I can acknowledge it without letting it control me.",
      "mood": "anxious",
      "tags": ["work", "anxiety", "preparation"],
      "isFavorite": false,
    },
    {
      "id": "4",
      "date": DateTime.now().subtract(const Duration(days: 3)),
      "content":
          "Spent time in nature today at the local park. The sound of birds chirping and the gentle breeze reminded me how healing it is to disconnect from technology and reconnect with the natural world. I felt so much more grounded afterward.",
      "mood": "peaceful",
      "tags": ["nature", "mindfulness", "grounding"],
      "isFavorite": true,
    },
  ];

  // Mock data for coping strategies
  final List<Map<String, dynamic>> _copingStrategies = [
    {
      "id": "1",
      "title": "Deep Breathing Exercise",
      "description": "Practice 4-7-8 breathing technique",
      "duration": 5,
      "isCompleted": true,
      "pointsReward": 10,
    },
    {
      "id": "2",
      "title": "Gratitude Journaling",
      "description": "Write down 3 things you're grateful for",
      "duration": 10,
      "isCompleted": false,
      "pointsReward": 15,
    },
    {
      "id": "3",
      "title": "Mindful Walking",
      "description": "Take a 10-minute mindful walk outdoors",
      "duration": 10,
      "isCompleted": false,
      "pointsReward": 20,
    },
    {
      "id": "4",
      "title": "Progressive Muscle Relaxation",
      "description": "Tense and release muscle groups systematically",
      "duration": 15,
      "isCompleted": true,
      "pointsReward": 25,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF0FA97A),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: MindWellnessHeader(
                mentalWellnessPoints: _mentalWellnessPoints,
                reflectionStreak: _reflectionStreak,
                onRefresh: _handleRefresh,
              ),
            ),
            SliverToBoxAdapter(
              child: ReflectionPromptCard(
                prompts: _reflectionPrompts,
                currentIndex: _currentPromptIndex,
                onPromptChanged: (index) {
                  setState(() {
                    _currentPromptIndex = index;
                  });
                },
              ),
            ),
            SliverToBoxAdapter(
              child: JournalEntryInterface(
                onEntryChanged: (text) {
                  setState(() {
                    _currentJournalEntry = text;
                  });
                },
                onSaveEntry: _saveJournalEntry,
                initialText: _currentJournalEntry,
              ),
            ),
            SliverToBoxAdapter(
              child: CopingMechanismTracker(
                copingStrategies: _copingStrategies,
                onStrategyCompleted: _handleStrategyCompleted,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
                child: Text(
                  'Previous Reflections',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = _journalEntries[index];
                  return JournalTimelineCard(
                    entry: entry,
                    onTap: () => _viewFullEntry(entry),
                    onEdit: () => _editEntry(entry),
                    onDelete: () => _deleteEntry(entry["id"] as String),
                    onShare: () => _shareEntry(entry),
                    onFavorite: () => _toggleFavorite(entry["id"] as String),
                  );
                },
                childCount: _journalEntries.length,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppSpace.x10),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _createNewJournalEntry,
          backgroundColor: const Color(0xFF0FA97A),
          foregroundColor: Colors.white,
          icon: CustomIconWidget(
            iconName: 'add',
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            'New Entry',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity( 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false, arguments: 0),
                    icon: CustomIconWidget(
                      iconName: 'home',
                      color: colorScheme.primary,
                      size: 16,
                    ),
                    label: Text('Home'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSpace.x3),
                    ),
                  ),
                ),
                SizedBox(width: AppSpace.x3),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/daily-check-in-screen'),
                    icon: CustomIconWidget(
                      iconName: 'check_circle',
                      color: Colors.white,
                      size: 16,
                    ),
                    label: Text('Check-in'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FA97A),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSpace.x3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      // Rotate to next prompt
      _currentPromptIndex =
          (_currentPromptIndex + 1) % _reflectionPrompts.length;
    });
  }

  void _saveJournalEntry() {
    if (_currentJournalEntry.trim().isEmpty) return;

    setState(() {
      _journalEntries.insert(0, {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "date": DateTime.now(),
        "content": _currentJournalEntry,
        "mood": "neutral",
        "tags": <String>[],
        "isFavorite": false,
      });
      _currentJournalEntry = '';
      _mentalWellnessPoints += 20; // Award points for journal entry
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Journal entry saved! +20 points earned'),
        backgroundColor: const Color(0xFF0FA97A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleStrategyCompleted(String strategyId) {
    setState(() {
      final strategyIndex = _copingStrategies.indexWhere(
        (strategy) => strategy["id"] == strategyId,
      );
      if (strategyIndex != -1) {
        final strategy = _copingStrategies[strategyIndex];
        final wasCompleted = strategy["isCompleted"] as bool? ?? false;
        strategy["isCompleted"] = !wasCompleted;

        if (!wasCompleted) {
          _mentalWellnessPoints += strategy["pointsReward"] as int? ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Strategy completed! +${strategy["pointsReward"]} points earned'),
              backgroundColor: const Color(0xFF0FA97A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  void _createNewJournalEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: 500, // Fixed height instead of percentage
          padding: Pad.card,
          child: Column(
            children: [
              Container(
                width: 48, // Fixed width instead of percentage
                height: 2, // Fixed height instead of percentage
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity( 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppSpace.x2),
              Text(
                'New Journal Entry',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: AppSpace.x2),
              Expanded(
                child: JournalEntryInterface(
                  onEntryChanged: (text) {
                    _currentJournalEntry = text;
                  },
                  onSaveEntry: () {
                    _saveJournalEntry();
                    Navigator.pop(context);
                  },
                  initialText: '',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewFullEntry(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: 500), // Fixed height instead of percentage
            padding: Pad.card,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Journal Entry',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpace.x2),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      entry["content"] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editEntry(Map<String, dynamic> entry) {
    // Implementation for editing entry
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit functionality coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteEntry(String entryId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Entry'),
          content: Text(
              'Are you sure you want to delete this journal entry? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _journalEntries
                      .removeWhere((entry) => entry["id"] == entryId);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Journal entry deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _shareEntry(Map<String, dynamic> entry) {
    // Implementation for sharing entry anonymously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anonymous sharing functionality coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleFavorite(String entryId) {
    setState(() {
      final entryIndex = _journalEntries.indexWhere(
        (entry) => entry["id"] == entryId,
      );
      if (entryIndex != -1) {
        final entry = _journalEntries[entryIndex];
        entry["isFavorite"] = !(entry["isFavorite"] as bool? ?? false);
      }
    });
  }
}
