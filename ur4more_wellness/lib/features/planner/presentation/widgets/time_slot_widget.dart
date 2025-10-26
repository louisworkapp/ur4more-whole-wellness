import 'package:flutter/material.dart';
import '../../../../design/mind_tokens.dart';
import '../../domain/plan_models.dart';
import 'time_block_widget.dart';

class TimeSlotWidget extends StatelessWidget {
  final DateTime time;
  final List<PlanBlock> blocks;
  final Function(CoachCategory) onAddBlock;
  final Function(PlanBlock) onUpdateBlock;
  final Function(String) onDeleteBlock;
  final Function() getAllBlocks; // Callback to get all blocks for conflict detection
  final Function(PlanBlock, DateTime) onBlockDropped; // Callback for when a block is dropped

  const TimeSlotWidget({
    super.key,
    required this.time,
    required this.blocks,
    required this.onAddBlock,
    required this.onUpdateBlock,
    required this.onDeleteBlock,
    required this.getAllBlocks,
    required this.onBlockDropped,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _formatTime(time),
              style: const TextStyle(
                color: MindColors.textSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Blocks area
          Expanded(
            child: DragTarget<PlanBlock>(
              onWillAcceptWithDetails: (details) {
                // Allow dropping if the block is not already in this time slot
                return !blocks.any((block) => block.id == details.data.id);
              },
              onAcceptWithDetails: (details) {
                // Update the block's time to this time slot
                final droppedBlock = details.data;
                final duration = droppedBlock.end.difference(droppedBlock.start);
                final newStartTime = time;
                final newEndTime = newStartTime.add(duration);
                
                final updatedBlock = droppedBlock.copyWith(
                  start: newStartTime,
                  end: newEndTime,
                );
                
                onBlockDropped(updatedBlock, time);
              },
              builder: (context, candidateData, rejectedData) {
                final isHighlighted = candidateData.isNotEmpty;
                return Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  decoration: BoxDecoration(
                    color: isHighlighted 
                        ? MindColors.brandBlue.withOpacity(0.1)
                        : MindColors.surfaceHover,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isHighlighted 
                          ? MindColors.brandBlue
                          : MindColors.outline.withOpacity(0.3),
                      width: isHighlighted ? 2 : 1,
                    ),
                  ),
                  child: blocks.isEmpty
                      ? _buildEmptySlot()
                      : Column(
                          children: blocks.map((block) {
                            return TimeBlockWidget(
                              block: block,
                              onUpdate: onUpdateBlock,
                              onDelete: onDeleteBlock,
                              getAllBlocks: getAllBlocks,
                            );
                          }).toList(),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Builder(
      builder: (context) => InkWell(
        onTap: () => _showAddBlockDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 60,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text(
              'Tap to add block',
              style: TextStyle(
                color: MindColors.textSub,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddBlockDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: MindColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Block at ${_formatTime(time)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MindColors.text,
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryButton(context, 'Mind Block', CoachCategory.mind),
            _buildCategoryButton(context, 'Body Block', CoachCategory.body),
            _buildCategoryButton(context, 'Spirit Block', CoachCategory.spirit),
            _buildCategoryButton(context, 'Work Block', CoachCategory.work),
            _buildCategoryButton(context, 'Errand Block', CoachCategory.errand),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String title, CoachCategory category) {
    final color = _getCategoryColor(category);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close bottom sheet
            onAddBlock(category);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(title),
        ),
      ),
    );
  }

  Color _getCategoryColor(CoachCategory category) {
    switch (category) {
      case CoachCategory.mind:
        return const Color(0xFF4CAF50); // Green
      case CoachCategory.body:
        return MindColors.brandBlue; // Brand blue
      case CoachCategory.spirit:
        return const Color(0xFFFFD700); // Gold
      case CoachCategory.work:
        return MindColors.textSub;
      case CoachCategory.errand:
        return MindColors.textSub;
    }
  }
}
