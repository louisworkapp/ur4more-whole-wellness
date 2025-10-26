import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/plan_models.dart';

class PlanRepository {
  static const _k = 'ur4_plan_blocks_v1';

  Future<List<PlanBlock>> loadForDay(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_k);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final all = list.map(PlanBlock.fromJson).toList();
    return all.where((b) =>
      b.start.year==day.year && b.start.month==day.month && b.start.day==day.day).toList();
  }

  Future<void> saveAll(List<PlanBlock> blocks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = blocks.map((b)=>b.toJson()).toList();
    await prefs.setString(_k, jsonEncode(jsonList));
  }

  Future<void> upsert(PlanBlock b) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_k);
    final list = raw==null ? <PlanBlock>[] :
      (jsonDecode(raw) as List).map((e)=>PlanBlock.fromJson(e)).toList();
    final i = list.indexWhere((x)=>x.id==b.id);
    if (i>=0) list[i] = b; else list.add(b);
    await prefs.setString(_k, jsonEncode(list.map((e)=>e.toJson()).toList()));
  }

  Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_k);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List).map((e)=>PlanBlock.fromJson(e)).toList();
    list.removeWhere((x) => x.id == id);
    await prefs.setString(_k, jsonEncode(list.map((e)=>e.toJson()).toList()));
  }
}
