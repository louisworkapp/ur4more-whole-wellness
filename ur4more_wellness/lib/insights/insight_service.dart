import 'insight_store.dart';

class MicroInsight {
  final String id;
  final double? avgDeltaMood;
  final double? avgDeltaUrge;
  final double? avgPostConfidence;
  final int count;
  
  MicroInsight({
    required this.id, 
    this.avgDeltaMood, 
    this.avgDeltaUrge, 
    this.avgPostConfidence, 
    required this.count
  });
}

class InsightService {
  final InsightStore store;
  
  InsightService(this.store);

  Future<MicroInsight?> forExercise(String id) async {
    final map = await store.byId();
    final list = (map[id] ?? []);
    if (list.isEmpty) return null;
    final last = list.length > 7 ? list.sublist(list.length-7) : list;

    double dm = 0, du = 0, pc = 0;
    int cMood = 0, cUrge = 0, cConf = 0;

    for (final s in last) {
      if (s.preMood != null && s.postMood != null) { 
        dm += (s.postMood! - s.preMood!); 
        cMood++; 
      }
      if (s.preUrge != null && s.postUrge != null) { 
        du += (s.postUrge! - s.preUrge!); 
        cUrge++; 
      }
      if (s.postConfidence != null) { 
        pc += s.postConfidence!; 
        cConf++; 
      }
    }
    
    return MicroInsight(
      id: id,
      avgDeltaMood: cMood > 0 ? dm / cMood : null,
      avgDeltaUrge: cUrge > 0 ? du / cUrge : null,
      avgPostConfidence: cConf > 0 ? pc / cConf : null,
      count: last.length
    );
  }
}
