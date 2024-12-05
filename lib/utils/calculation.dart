double percentageChange(double oldValue, double newValue) {
  if (oldValue == 0) {
    return 99;
  }
  return ((newValue - oldValue) / oldValue) * 100;
}
