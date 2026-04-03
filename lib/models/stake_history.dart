class StakeHistory {
  final DateTime date;
  final double staked;

  StakeHistory({required this.date, required this.staked});

  factory StakeHistory.fromJson(Map<String, dynamic> json) {
    return StakeHistory(
      date: DateTime.fromMillisecondsSinceEpoch((json['t'] as int) * 1000),
      staked: json['tS'] / 1000000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      't': date.millisecondsSinceEpoch ~/ 1000,
      'tS': staked,
    };
  }
}
