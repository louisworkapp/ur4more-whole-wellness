import '../domain/plan_models.dart';

class BlockConflictService {
  /// Checks if a block would conflict with existing blocks
  static List<PlanBlock> findConflicts(PlanBlock newBlock, List<PlanBlock> existingBlocks) {
    final conflicts = <PlanBlock>[];
    
    for (final existingBlock in existingBlocks) {
      if (existingBlock.id == newBlock.id) continue; // Skip the same block
      
      // Check if blocks overlap
      if (_blocksOverlap(newBlock, existingBlock)) {
        conflicts.add(existingBlock);
      }
    }
    
    return conflicts;
  }
  
  /// Checks if two blocks overlap in time
  static bool _blocksOverlap(PlanBlock block1, PlanBlock block2) {
    return block1.start.isBefore(block2.end) && block2.start.isBefore(block1.end);
  }
  
  /// Auto-fills by blocking off time slots for the extended duration
  static List<PlanBlock> autoFillConflicts(PlanBlock newBlock, List<PlanBlock> existingBlocks) {
    final adjustedBlocks = <PlanBlock>[];
    
    // Add all blocks that come before the new block (unchanged)
    for (final block in existingBlocks) {
      if (block.id != newBlock.id && block.start.isBefore(newBlock.start)) {
        adjustedBlocks.add(block);
      }
    }
    
    // Add the new block with extended duration
    adjustedBlocks.add(newBlock);
    
    // Remove any blocks that fall within the new block's extended time range
    // (These blocks get "blocked off" by the extended duration)
    for (final block in existingBlocks) {
      if (block.id != newBlock.id) {
        // Check if this block overlaps with the new block's extended time range
        if (!_blocksOverlap(newBlock, block)) {
          // Block doesn't overlap, keep it
          adjustedBlocks.add(block);
        }
        // If it overlaps, we don't add it (it gets blocked off)
      }
    }
    
    // Sort final result by start time
    adjustedBlocks.sort((a, b) => a.start.compareTo(b.start));
    
    return adjustedBlocks;
  }
  
  /// Gets the next available time slot for a block of given duration
  static DateTime getNextAvailableSlot(DateTime startTime, Duration duration, List<PlanBlock> existingBlocks) {
    final endTime = startTime.add(duration);
    final testBlock = PlanBlock(
      id: 'temp',
      title: 'Test',
      category: CoachCategory.work,
      start: startTime,
      end: endTime,
    );
    
    final conflicts = findConflicts(testBlock, existingBlocks);
    
    if (conflicts.isEmpty) {
      return startTime; // No conflicts, use the original time
    }
    
    // Find the latest end time among conflicts
    final latestConflictEnd = conflicts.map((block) => block.end).reduce((a, b) => a.isAfter(b) ? a : b);
    
    // Return the time right after the latest conflict
    return latestConflictEnd;
  }
  
  /// Gets a preview of all blocks that will be blocked off by the extended duration
  static Map<String, dynamic> getAutoFillPreview(PlanBlock newBlock, List<PlanBlock> existingBlocks) {
    final blocksToBlockOff = <PlanBlock>[];
    
    // Find blocks that will be blocked off by the new block's extended duration
    for (final block in existingBlocks) {
      if (block.id != newBlock.id) {
        // Check if this block overlaps with the new block's extended time range
        if (_blocksOverlap(newBlock, block)) {
          blocksToBlockOff.add(block);
        }
      }
    }
    
    // Sort by start time
    blocksToBlockOff.sort((a, b) => a.start.compareTo(b.start));
    
    // Create preview showing which blocks will be blocked off
    final preview = <Map<String, dynamic>>[];
    
    for (final block in blocksToBlockOff) {
      preview.add({
        'block': block,
        'oldStart': block.start,
        'oldEnd': block.end,
        'action': 'blocked_off', // This block will be removed/blocked
        'reason': 'Overlaps with extended duration',
      });
    }
    
    return {
      'totalAffected': blocksToBlockOff.length,
      'preview': preview,
      'newBlock': newBlock,
      'action': 'block_off', // We're blocking off time slots, not shifting
    };
  }
  
  /// Formats duration in a human-readable way
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }
  
  /// Formats time shift in a human-readable way
  static String formatTimeShift(Duration shift) {
    if (shift.inMinutes < 60) {
      return '${shift.inMinutes}m later';
    } else {
      final hours = shift.inHours;
      final minutes = shift.inMinutes % 60;
      if (minutes == 0) {
        return '${hours}h later';
      } else {
        return '${hours}h ${minutes}m later';
      }
    }
  }
}
