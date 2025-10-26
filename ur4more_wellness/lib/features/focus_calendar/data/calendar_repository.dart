import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/block_models.dart';

class CalendarRepository {
  static const _key = 'focus_calendar_blocks_v1';

  Future<List<PlanBlock>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw==null) return [];
    return (jsonDecode(raw) as List).map((e)=>PlanBlock.fromJson(e)).toList();
  }

  Future<void> saveAll(List<PlanBlock> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items.map((e)=>e.toJson()).toList()));
  }

  Future<List<PlanBlock>> loadForDay(DateTime day) async {
    final all = await loadAll();
    return all.where((b) =>
      b.start.year==day.year && b.start.month==day.month && b.start.day==day.day
    ).toList()..sort((a,b)=>a.start.compareTo(b.start));
  }

  Future<void> upsert(PlanBlock b) async {
    final all = await loadAll();
    final i = all.indexWhere((x)=>x.id==b.id);
    if (i>=0) all[i]=b; else all.add(b);
    await saveAll(all);
  }

  Future<void> remove(String id) async {
    final all = await loadAll();
    await saveAll(all.where((x)=>x.id!=id).toList());
  }
}