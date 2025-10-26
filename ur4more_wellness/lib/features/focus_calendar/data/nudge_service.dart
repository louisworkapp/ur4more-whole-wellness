class NudgeService {
  static bool isFreshStart(DateTime now) {
    final monday = now.weekday == DateTime.monday;
    final firstOfMonth = now.day == 1;
    return monday || firstOfMonth;
  }
}
