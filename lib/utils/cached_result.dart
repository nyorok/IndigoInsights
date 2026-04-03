class CachedResult<T> {
  final T value;
  final DateTime _fetchedAt;

  CachedResult(this.value) : _fetchedAt = DateTime.now();

  bool isValid(Duration ttl) => DateTime.now().difference(_fetchedAt) < ttl;

  DateTime get fetchedAt => _fetchedAt;
}
