String millisecondsToTimeString(double millis) {
  double seconds = millis / 1000.0;
  double minutes = seconds / 60.0;
  int intMinutes = minutes.toInt();
  double mSeconds = minutes - intMinutes;
  int intSeconds = (mSeconds * 60).toInt();
  return "$intMinutes:${intSeconds.toString().padLeft(2, "0")}";
}
