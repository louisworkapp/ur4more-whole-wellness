import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('core', help: 'Path to core exercises JSON file')
    ..addOption('faith', help: 'Path to faith exercises JSON file')
    ..addFlag('dry-run', help: 'Print diff without writing files')
    ..addFlag('write', help: 'Write updated files in place');

  final results = parser.parse(arguments);
  
  if (results['core'] == null || results['faith'] == null) {
    print('Usage: dart run tools/exercise_upgrade.dart --core <path> --faith <path> [--dry-run|--write]');
    exit(1);
  }

  final corePath = results['core'] as String;
  final faithPath = results['faith'] as String;
  final isDryRun = results['dry-run'] as bool;
  final shouldWrite = results['write'] as bool;

  if (isDryRun == shouldWrite) {
    print('Error: Specify either --dry-run or --write, not both');
    exit(1);
  }

  try {
    final coreFile = File(corePath);
    final faithFile = File(faithPath);
    
    if (!coreFile.existsSync()) {
      print('Error: Core file not found: $corePath');
      exit(1);
    }
    
    if (!faithFile.existsSync()) {
      print('Error: Faith file not found: $faithPath');
      exit(1);
    }

    final coreContent = json.decode(coreFile.readAsStringSync()) as Map<String, dynamic>;
    final faithContent = json.decode(faithFile.readAsStringSync()) as Map<String, dynamic>;

    final upgradedCore = _upgradeExercises(coreContent, 'core');
    final upgradedFaith = _upgradeExercises(faithContent, 'faith');

    if (isDryRun) {
      print('=== CORE EXERCISES UPGRADE ===');
      _printDiff(coreContent, upgradedCore);
      print('\n=== FAITH EXERCISES UPGRADE ===');
      _printDiff(faithContent, upgradedFaith);
    } else {
      final encoder = JsonEncoder.withIndent('  ');
      coreFile.writeAsStringSync(encoder.convert(upgradedCore));
      faithFile.writeAsStringSync(encoder.convert(upgradedFaith));
      print('Successfully upgraded exercise files');
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

Map<String, dynamic> _upgradeExercises(Map<String, dynamic> content, String packType) {
  final exercises = List<Map<String, dynamic>>.from(content['exercises'] as List);
  final existingIds = exercises.map((e) => e['id'] as String).toSet();
  final newExercises = <Map<String, dynamic>>[];

  // Find L1 exercises that don't have L2/L3 variants
  final l1Exercises = exercises.where((e) => e['level'] == 'L1').toList();
  
  for (final l1 in l1Exercises) {
    final baseId = (l1['id'] as String).replaceAll('_l1', '');
    final l2Id = '${baseId}_l2';
    final l3Id = '${baseId}_l3';
    
    if (!existingIds.contains(l2Id)) {
      newExercises.add(_createL2Variant(l1, baseId));
    }
    
    if (!existingIds.contains(l3Id)) {
      newExercises.add(_createL3Variant(l1, baseId));
    }
  }

  final result = Map<String, dynamic>.from(content);
  result['exercises'] = [...exercises, ...newExercises];
  return result;
}

Map<String, dynamic> _createL2Variant(Map<String, dynamic> l1, String baseId) {
  final l2 = Map<String, dynamic>.from(l1);
  final exerciseFamily = _getExerciseFamily(baseId);
  
  l2['id'] = '${baseId}_l2';
  l2['title'] = '${(l1['title'] as String).replaceAll(' (L1)', '')} (L2)';
  l2['level'] = 'L2';
  l2['xp'] = (l1['xp'] as int) + 5;
  
  // Adjust timing
  if (l1.containsKey('expectedSeconds')) {
    final seconds = l1['expectedSeconds'] as int;
    l2['expectedSeconds'] = (seconds * 1.4).round(); // +40%
  } else if (l1.containsKey('timerSeconds')) {
    final seconds = l1['timerSeconds'] as int;
    l2['timerSeconds'] = (seconds * 1.4).round(); // +40%
  }
  
  // Expand steps based on family
  l2['steps'] = _expandStepsL2((l1['steps'] as List).cast<String>(), exerciseFamily);
  l2['petersonAimUp'] = _upgradeAimUpL2(l1['petersonAimUp'] as String, exerciseFamily);
  
  return l2;
}

Map<String, dynamic> _createL3Variant(Map<String, dynamic> l1, String baseId) {
  final l3 = Map<String, dynamic>.from(l1);
  final exerciseFamily = _getExerciseFamily(baseId);
  
  l3['id'] = '${baseId}_l3';
  l3['title'] = '${(l1['title'] as String).replaceAll(' (L1)', '')} (L3)';
  l3['level'] = 'L3';
  l3['xp'] = (l1['xp'] as int) + 10;
  
  // Adjust timing
  if (l1.containsKey('expectedSeconds')) {
    final seconds = l1['expectedSeconds'] as int;
    l3['expectedSeconds'] = (seconds * 1.8).round(); // +80%
  } else if (l1.containsKey('timerSeconds')) {
    final seconds = l1['timerSeconds'] as int;
    // Cap timers appropriately
    final newSeconds = (seconds * 1.8).round();
    if (exerciseFamily == 'meditation') {
      l3['timerSeconds'] = newSeconds > 900 ? 900 : newSeconds;
    } else {
      l3['timerSeconds'] = newSeconds > 600 ? 600 : newSeconds;
    }
  }
  
  // Expand steps based on family
  l3['steps'] = _expandStepsL3((l1['steps'] as List).cast<String>(), exerciseFamily);
  l3['petersonAimUp'] = _upgradeAimUpL3(l1['petersonAimUp'] as String, exerciseFamily);
  
  return l3;
}

String _getExerciseFamily(String baseId) {
  if (baseId.contains('thought_record')) return 'thought_record';
  if (baseId.contains('breath')) return 'breath';
  if (baseId.contains('values')) return 'values';
  if (baseId.contains('if_then')) return 'if_then';
  if (baseId.contains('exposure')) return 'exposure';
  if (baseId.contains('commitment')) return 'commitment';
  if (baseId.contains('joy') || baseId.contains('gratitude')) return 'gratitude';
  if (baseId.contains('relapse')) return 'relapse';
  if (baseId.contains('identity')) return 'identity';
  if (baseId.contains('confession')) return 'confession';
  if (baseId.contains('serve')) return 'serve';
  if (baseId.contains('meditation')) return 'meditation';
  if (baseId.contains('truth')) return 'truth';
  return 'generic';
}

List<String> _expandStepsL2(List<String> steps, String family) {
  switch (family) {
    case 'thought_record':
      return [
        ...steps,
        'Label the distortion (e.g., catastrophizing, mind-reading).',
        'Plan a tiny behavioral experiment to test it.'
      ];
    case 'breath':
      return steps; // Just extend timer
    case 'values':
      return [
        ...steps,
        'Define each top value in 1 sentence.',
        'One 10-minute action to realign.'
      ];
    case 'if_then':
      return [
        ...steps,
        'Tweak the environment (remove friction or add cue).',
        'Ping a buddy or set a reminder.'
      ];
    case 'exposure':
      return [
        ...steps,
        'Write a 1-line coping script to read before/after.',
        'Commit to rungs 1–2 this week.'
      ];
    case 'commitment':
      return [
        ...steps,
        'Name the value it serves.',
        'Choose a small penalty if missed (e.g., 10 push-ups, \$5 charity).'
      ];
    case 'gratitude':
      return [
        ...steps,
        'Plan 1 repeat before noon tomorrow.'
      ];
    case 'relapse':
      return [
        ...steps,
        '2-line calm-script to read during urge.',
        'Buddy to text if urge >7.'
      ];
    case 'identity':
      return [
        ...steps,
        'Plan a 5-minute action to live that identity today.'
      ];
    case 'confession':
      return [
        ...steps,
        'If repair is needed, plan a small restitution step.'
      ];
    case 'serve':
      return [
        ...steps,
        'Choose a verse motive.',
        'Do it within 24h; log mood change.'
      ];
    case 'meditation':
      return [
        'Read slowly 3x.',
        'What stirs? One word/phrase.',
        'What obedience does this call for today?'
      ];
    case 'truth':
      return [
        ...steps,
        'One action today; share truth with a trusted person.'
      ];
    default:
      return steps;
  }
}

List<String> _expandStepsL3(List<String> steps, String family) {
  switch (family) {
    case 'thought_record':
      return [
        ...steps,
        'One identity statement aligned with truth.',
        'Schedule a 24h check to re-rate emotion after your action.'
      ];
    case 'breath':
      return [
        'Breathing cycles for ${(steps.length > 0 ? '170s' : '170s')}',
        'Last 10s: whisper gratitude to God'
      ];
    case 'values':
      return [
        ...steps,
        'One daily practice (≤5 min) that honors it.',
        'One weekly practice (≤30 min).',
        'Plan first practice today.'
      ];
    case 'if_then':
      return [
        ...steps,
        'Backup if–then when Plan A fails.',
        'Schedule both in calendar.'
      ];
    case 'exposure':
      return [
        ...steps,
        'Brief imaginal exposure for rung 1.',
        'Message coach/buddy after completion.'
      ];
    case 'commitment':
      return [
        ...steps,
        'Tell one trusted person; schedule a 48h check.'
      ];
    case 'gratitude':
      return [
        ...steps,
        'Pick one joy you can create for someone else tomorrow.',
        'Schedule it.'
      ];
    case 'relapse':
      return [
        ...steps,
        'Set one environment lockout (filter, timer, remove cue).',
        'Schedule a 10-minute post-event review slot.'
      ];
    case 'identity':
      return [
        ...steps,
        'Speak it aloud once.',
        'Send it to a trusted friend; live one action today.'
      ];
    case 'confession':
      return [
        ...steps,
        'Ask a mentor to check in within 48h.'
      ];
    case 'serve':
      return [
        ...steps,
        'Plan 7 days of small service acts (1/day).',
        'Schedule the first two days now.'
      ];
    case 'meditation':
      return [
        'Read slowly 3x.',
        'What stirs? One word/phrase.',
        'What obedience does this call for today?'
      ];
    case 'truth':
      return [
        ...steps,
        'Share truth with a trusted person.'
      ];
    default:
      return steps;
  }
}

String _upgradeAimUpL2(String original, String family) {
  switch (family) {
    case 'thought_record':
      return 'Name the error; act toward truth.';
    case 'breath':
      return 'Extend calm; extend control.';
    case 'values':
      return 'Define the good; then do it.';
    case 'if_then':
      return 'Design beats willpower.';
    case 'exposure':
      return 'Courage repeats; fear retreats.';
    case 'commitment':
      return 'Value + cost creates follow-through.';
    case 'gratitude':
      return 'Rehearse good to multiply it.';
    case 'relapse':
      return 'Prepare words; prevent falls.';
    case 'identity':
      return 'Identity → action → habit.';
    case 'confession':
      return 'Repentance restores order.';
    case 'serve':
      return 'Service lifts both giver and world.';
    case 'meditation':
      return 'Attend longer; be shaped deeper.';
    case 'truth':
      return 'Truth shared strengthens resolve.';
    default:
      return original;
  }
}

String _upgradeAimUpL3(String original, String family) {
  switch (family) {
    case 'thought_record':
      return 'Truth changes identity; identity guides action.';
    case 'breath':
      return 'Peace anchors purpose.';
    case 'values':
      return 'Small order compounds to purpose.';
    case 'if_then':
      return 'Plan A fails; Plan B still aims up.';
    case 'exposure':
      return 'Practice today; step higher tomorrow.';
    case 'commitment':
      return 'Public promise sharpens resolve.';
    case 'gratitude':
      return 'Joy grows when shared.';
    case 'relapse':
      return 'Design life for the good.';
    case 'identity':
      return 'Confessed truth strengthens identity.';
    case 'confession':
      return 'Truth + accountability = growth.';
    case 'serve':
      return 'Habits of love build mission.';
    case 'meditation':
      return 'Attend longer; be shaped deeper.';
    case 'truth':
      return 'Truth shared strengthens resolve.';
    default:
      return original;
  }
}

void _printDiff(Map<String, dynamic> original, Map<String, dynamic> upgraded) {
  final originalExercises = (original['exercises'] as List).length;
  final upgradedExercises = (upgraded['exercises'] as List).length;
  final newCount = upgradedExercises - originalExercises;
  
  print('Exercises: $originalExercises → $upgradedExercises (+$newCount)');
  
  final originalIds = (original['exercises'] as List).map((e) => e['id'] as String).toSet();
  final upgradedIds = (upgraded['exercises'] as List).map((e) => e['id'] as String).toSet();
  final newIds = upgradedIds.difference(originalIds);
  
  if (newIds.isNotEmpty) {
    print('New exercises:');
    for (final id in newIds.toList()..sort()) {
      print('  + $id');
    }
  }
}

