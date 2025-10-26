import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../design/mind_tokens.dart';
import '../../domain/plan_models.dart';
import '../../data/block_conflict_service.dart';

class TimeBlockWidget extends StatefulWidget {
  final PlanBlock block;
  final Function(PlanBlock) onUpdate;
  final Function(String) onDelete;
  final Function() getAllBlocks; // Callback to get all blocks for conflict detection

  const TimeBlockWidget({
    super.key,
    required this.block,
    required this.onUpdate,
    required this.onDelete,
    required this.getAllBlocks,
  });

  @override
  State<TimeBlockWidget> createState() => _TimeBlockWidgetState();
}

class _TimeBlockWidgetState extends State<TimeBlockWidget> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.block.title);
    _notesController = TextEditingController(text: widget.block.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
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

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(widget.block.category);
    final icon = _getCategoryIcon(widget.block.category);

    return Draggable<PlanBlock>(
      data: widget.block,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.block.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatTime(widget.block.start)} - ${_formatTime(widget.block.end)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5), style: BorderStyle.solid),
        ),
        child: const Center(
          child: Text(
            'Moving...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MindColors.textSub,
            ),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: _isEditing ? _buildEditMode(color, icon) : _buildViewMode(color, icon),
      ),
    );
  }

  Widget _buildViewMode(Color color, IconData icon) {
    return InkWell(
      onTap: () => setState(() => _isEditing = true),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.block.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '${_formatTime(widget.block.start)} - ${_formatTime(widget.block.end)} (${widget.block.duration.inMinutes}m)',
                  style: const TextStyle(
                    color: MindColors.textSub,
                    fontSize: 12,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      setState(() => _isEditing = true);
                    } else if (value == 'delete') {
                      _showDeleteDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (widget.block.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                widget.block.notes!,
                style: const TextStyle(
                  color: MindColors.textSub,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode(Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'Block title',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.mic, size: 16),
                onPressed: _startVoiceInput,
                tooltip: 'Voice input',
              ),
              IconButton(
                icon: const Icon(Icons.check, size: 16, color: Colors.green),
                onPressed: _saveChanges,
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                onPressed: () => setState(() => _isEditing = false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 2,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'Notes (optional)',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatTime(widget.block.start)} - ${_formatTime(widget.block.end)}',
                  style: const TextStyle(
                    color: MindColors.textSub,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _showTimePicker,
                child: const Text('Time', style: TextStyle(fontSize: 11)),
              ),
              TextButton(
                onPressed: _showDurationPicker,
                child: const Text('Duration', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final updatedBlock = widget.block.copyWith(
      title: _titleController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
    widget.onUpdate(updatedBlock);
    setState(() => _isEditing = false);
    HapticFeedback.lightImpact();
  }

  void _startVoiceInput() {
    // TODO: Implement voice input using speech_to_text
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDurationPicker() {
    final currentDuration = widget.block.duration.inMinutes;
    int selectedMinutes = currentDuration;
    final TextEditingController inputController = TextEditingController(text: currentDuration.toString());
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Duration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current duration display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MindColors.surfaceHover,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Duration:', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('${BlockConflictService.formatDuration(Duration(minutes: selectedMinutes))}', 
                         style: const TextStyle(color: MindColors.brandBlue, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Slider for duration (up to 8 hours = 480 minutes)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Slide to adjust:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Slider(
                    value: selectedMinutes.toDouble(),
                    min: 5,
                    max: 480, // 8 hours
                    divisions: 95, // 5-minute increments
                    label: BlockConflictService.formatDuration(Duration(minutes: selectedMinutes)),
                    onChanged: (value) {
                      setState(() {
                        selectedMinutes = value.round();
                        inputController.text = selectedMinutes.toString();
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Manual input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Or enter manually (minutes):', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: inputController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter minutes (5-480)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed >= 5 && parsed <= 480) {
                        setState(() {
                          selectedMinutes = parsed;
                        });
                      }
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Conflict warning (if any)
              if (_hasConflict(selectedMinutes)) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This duration will block off overlapping time slots. Existing blocks in those times will be removed.',
                          style: const TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MindColors.surfaceHover,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: MindColors.outline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_fix_high, color: MindColors.brandBlue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Time slots that overlap with the extended duration will be blocked off and existing blocks removed.',
                          style: const TextStyle(fontSize: 12, color: MindColors.textSub),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (_hasConflict(selectedMinutes)) ...[
              TextButton(
                onPressed: () {
                  final newEnd = widget.block.start.add(Duration(minutes: selectedMinutes));
                  final updatedBlock = widget.block.copyWith(end: newEnd);
                  
                  // Quick auto-fill without confirmation
                  final allBlocks = widget.getAllBlocks();
                  final adjustedBlocks = BlockConflictService.autoFillConflicts(updatedBlock, allBlocks);
                  
                  // Update all blocks
                  for (final block in adjustedBlocks) {
                    widget.onUpdate(block);
                  }
                  
                  Navigator.pop(context);
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Duration set! ${adjustedBlocks.length - 1} blocks blocked off.'),
                      backgroundColor: MindColors.lime,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Quick Block Off'),
              ),
            ],
            ElevatedButton(
              onPressed: () {
                final newEnd = widget.block.start.add(Duration(minutes: selectedMinutes));
                final updatedBlock = widget.block.copyWith(end: newEnd);
                
                // Check if any blocks will be affected
                final allBlocks = widget.getAllBlocks();
                final willAffectBlocks = _hasConflict(selectedMinutes);
                
                if (willAffectBlocks) {
                  // Show confirmation dialog for auto-fill
                  _showAutoFillConfirmation(updatedBlock, []);
                } else {
                  // No blocks affected, just update
                  widget.onUpdate(updatedBlock);
                  Navigator.pop(context);
                }
              },
              child: Text(_hasConflict(selectedMinutes) ? 'Preview & Block Off' : 'Set Duration'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAutoFillConfirmation(PlanBlock updatedBlock, List<PlanBlock> conflicts) {
    final allBlocks = widget.getAllBlocks();
    final preview = BlockConflictService.getAutoFillPreview(updatedBlock, allBlocks);
    final totalAffected = preview['totalAffected'] as int;
    final previewData = preview['preview'] as List<Map<String, dynamic>>;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Fill Schedule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Setting this duration will block off $totalAffected blocks. These blocks will be removed to make room for the extended duration.',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Show preview of changes
              const Text('Schedule Changes:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
              
              // New block
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MindColors.lime.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MindColors.lime.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(updatedBlock.category), size: 16, color: _getCategoryColor(updatedBlock.category)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(updatedBlock.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            '${_formatTime(updatedBlock.start)} - ${_formatTime(updatedBlock.end)} (${BlockConflictService.formatDuration(updatedBlock.duration)})',
                            style: const TextStyle(fontSize: 12, color: MindColors.textSub),
                          ),
                        ],
                      ),
                    ),
                    const Text('NEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: MindColors.lime)),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Blocks that will be blocked off
              ...previewData.map((item) {
                final block = item['block'] as PlanBlock;
                final oldStart = item['oldStart'] as DateTime;
                final oldEnd = item['oldEnd'] as DateTime;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(block.category), size: 16, color: _getCategoryColor(block.category)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(block.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              '${_formatTime(oldStart)} - ${_formatTime(oldEnd)} (${BlockConflictService.formatDuration(block.duration)})',
                              style: const TextStyle(fontSize: 12, color: MindColors.textSub),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.block, size: 16, color: Colors.red),
                    ],
                  ),
                );
              }),
              
              const SizedBox(height: 16),
              const Text(
                'This will block off the overlapping time slots and remove the affected blocks. Continue?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close confirmation dialog
              Navigator.pop(context); // Close duration picker
              
              // Apply auto-fill
              final adjustedBlocks = BlockConflictService.autoFillConflicts(updatedBlock, allBlocks);
              
              // Update all blocks
              for (final block in adjustedBlocks) {
                widget.onUpdate(block);
              }
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Duration set! $totalAffected blocks blocked off.'),
                  backgroundColor: MindColors.lime,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Block Off & Set'),
          ),
        ],
      ),
    );
  }
  
  bool _hasConflict(int newDurationMinutes) {
    final newEnd = widget.block.start.add(Duration(minutes: newDurationMinutes));
    final testBlock = widget.block.copyWith(end: newEnd);
    
    // Get all blocks for the same day
    final allBlocks = widget.getAllBlocks();
    
    // Check if any blocks will overlap with the extended duration
    for (final block in allBlocks) {
      if (block.id != widget.block.id) {
        // Check if this block overlaps with the new extended time range
        if (testBlock.start.isBefore(block.end) && block.start.isBefore(testBlock.end)) {
          return true; // There are blocks that will be blocked off
        }
      }
    }
    
    return false;
  }

  void _showTimePicker() {
    final currentTime = TimeOfDay.fromDateTime(widget.block.start);
    int hour = currentTime.hour;
    int minute = currentTime.minute;
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
                
                final newStart = DateTime(
                  widget.block.start.year,
                  widget.block.start.month,
                  widget.block.start.day,
                  finalHour,
                  minute,
                );
                final duration = widget.block.end.difference(widget.block.start);
                final newEnd = newStart.add(duration);
                
                final updatedBlock = widget.block.copyWith(
                  start: newStart,
                  end: newEnd,
                );
                widget.onUpdate(updatedBlock);
                Navigator.pop(context);
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Block'),
        content: const Text('Are you sure you want to delete this time block?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete(widget.block.id);
              HapticFeedback.lightImpact();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
