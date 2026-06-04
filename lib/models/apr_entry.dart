class AprEntry {
  final String key;
  final double value;

  AprEntry({required this.key, required this.value});

  factory AprEntry.fromJson(Map<String, dynamic> json) => AprEntry(
    key: json['key'] as String,
    value: (json['value'] as num).toDouble(),
  );
}
