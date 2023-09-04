class StakeHistory {
  final DateTime date;
  final double staked;

  StakeHistory({required this.date, required this.staked});

  factory StakeHistory.fromJson(Map<String, dynamic> json) {
    return StakeHistory(
      date: DateTime.parse(json['timestamp']),
      staked: json['totalStake'] / 1000000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': date,
      'totalStake': staked,
    };
  }
}
