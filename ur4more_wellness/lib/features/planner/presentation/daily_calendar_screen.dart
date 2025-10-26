import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../design/mind_tokens.dart';
import '../domain/plan_models.dart';
import '../data/plan_repository.dart';
import 'widgets/time_block_widget.dart';
import 'widgets/time_slot_widget.dart';

class DailyCalendarScreen extends StatefulWidget {
  final DateTime selectedDate;
  const DailyCalendarScreen({super.key, required this.selectedDate});

  @override
  State<DailyCalendarScreen> createState() => _DailyCalendarScreenState();
}

class _DailyCalendarScreenState extends State<DailyCalendarScreen> {
  final PlanRepository _repository = PlanRepository();
  List<PlanBlock> _blocks = [];
  bool _isLoading = true;
  
  // Time slots from 6 AM to 10 PM
  final List<int> _timeSlots = List.generate(17, (index) => 6 + index);

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  Future<void> _loadBlocks() async {
    setState(() => _isLoading = true);
    final blocks = await _repository.loadForDay(widget.selectedDate);
    setState(() {
      _blocks = blocks;
      _isLoading = false;
    });
  }

  Future<void> _addBlock(DateTime startTime, CoachCategory category) async {
    final endTime = startTime.add(const Duration(hours: 1));
    final block = PlanBlock(
      id: 'block_${startTime.millisecondsSinceEpoch}',
      title: _getDefaultTitle(category),
      category: category,
      start: startTime,
      end: endTime,
      fromCoach: false,
    );
    
    await _repository.upsert(block);
    await _loadBlocks();
  }

  String _getDefaultTitle(CoachCategory category) {
    switch (category) {
      case CoachCategory.mind:
        return 'Mind: Focus Time';
      case CoachCategory.body:
        return 'Body: Exercise';
      case CoachCategory.spirit:
        return 'Spirit: Reflection';
      case CoachCategory.work:
        return 'Work: Task';
      case CoachCategory.errand:
        return 'Errand';
      default:
        return 'Block';
    }
  }

  Future<void> _deleteBlock(String blockId) async {
    await _repository.remove(blockId);
    await _loadBlocks();
  }

  void _handleBlockDropped(PlanBlock updatedBlock, DateTime newTime) async {
    // Update the block with its new time
    await _repository.upsert(updatedBlock);
    await _loadBlocks();
  }

  Future<void> _updateBlock(PlanBlock block) async {
    await _repository.upsert(block);
    await _loadBlocks();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildMindTheme(Theme.of(context)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}'),
          backgroundColor: MindColors.bg,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddBlockDialog(),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildCalendar(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddBlockDialog(),
          backgroundColor: MindColors.lime,
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _timeSlots.length,
          itemBuilder: (context, index) {
            final hour = _timeSlots[index];
            final timeSlot = DateTime(
              widget.selectedDate.year,
              widget.selectedDate.month,
              widget.selectedDate.day,
              hour,
            );
            
            return TimeSlotWidget(
              time: timeSlot,
              blocks: _blocks.where((block) => 
                block.start.hour == hour
              ).toList(),
              onAddBlock: (category) => _addBlock(timeSlot, category),
              onUpdateBlock: _updateBlock,
              onDeleteBlock: _deleteBlock,
              getAllBlocks: () => _blocks, // Pass all blocks for conflict detection
              onBlockDropped: _handleBlockDropped,
            );
          },
        ),
      ),
    );
  }

  void _showAddBlockDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildAddBlockSheet(),
    );
  }

  Widget _buildAddBlockSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: MindColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Time Block',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          const Text('Choose category:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: CoachCategory.values.map((category) {
              return _buildCategoryChip(category);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(CoachCategory category) {
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);
    
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showTimePicker(category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              category.name.toUpperCase(),
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker(CoachCategory category) {
    final now = TimeOfDay.now();
    int hour = now.hour;
    int minute = now.minute;
    bool isAM = hour < 12;
    
    // Convert to 12-hour format for display
    if (hour == 0) hour = 12;
    else if (hour > 12) hour -= 12;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Hour input
                  Column(
                    children: [
                      const Text('Hour', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                hour = (hour == 1) ? 12 : hour - 1;
                              });
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Container(
                            width: 50,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: MindColors.surfaceHover,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              hour.toString().padLeft(2, '0'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                hour = (hour == 12) ? 1 : hour + 1;
                              });
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  // Minute input
                  Column(
                    children: [
                      const Text('Minute', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                minute = (minute == 0) ? 59 : minute - 1;
                              });
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Container(
                            width: 50,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: MindColors.surfaceHover,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              minute.toString().padLeft(2, '0'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                minute = (minute == 59) ? 0 : minute + 1;
                              });
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // AM/PM selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isAM = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isAM ? MindColors.brandBlue : MindColors.surfaceHover,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'AM',
                        style: TextStyle(
                          color: isAM ? Colors.white : MindColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => isAM = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: !isAM ? MindColors.brandBlue : MindColors.surfaceHover,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PM',
                        style: TextStyle(
                          color: !isAM ? Colors.white : MindColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Convert back to 24-hour format
                int finalHour = hour;
                if (!isAM && hour != 12) finalHour += 12;
                if (isAM && hour == 12) finalHour = 0;
                
                final startTime = DateTime(
                  widget.selectedDate.year,
                  widget.selectedDate.month,
                  widget.selectedDate.day,
                  finalHour,
                  minute,
                );
                _addBlock(startTime, category);
                Navigator.pop(context);
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(CoachCategory category) {
    switch (category) {
      case CoachCategory.mind:
        return const Color(0xFF4CAF50); // Green
      case CoachCategory.body:
        return MindColors.brandBlue; // Blue
      case CoachCategory.spirit:
        return const Color(0xFFFFD700); // Gold
      case CoachCategory.work:
        return MindColors.textSub;
      case CoachCategory.errand:
        return MindColors.textSub;
    }
  }

  IconData _getCategoryIcon(CoachCategory category) {
    switch (category) {
      case CoachCategory.mind:
        return Icons.psychology;
      case CoachCategory.body:
        return Icons.fitness_center;
      case CoachCategory.spirit:
        return Icons.auto_awesome;
      case CoachCategory.work:
        return Icons.work;
      case CoachCategory.errand:
        return Icons.shopping_cart;
    }
  }
}
