class NudgeService {
  static bool isFreshStart(DateTime now) {
    final monday = now.weekday == DateTime.monday;
    final first = now.day == 1;
    return monday || first;
  }
}
