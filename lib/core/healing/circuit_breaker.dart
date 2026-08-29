enum CircuitState { closed, open, halfOpen }

class CircuitBreaker {
  CircuitBreaker({
    this.failureThreshold = 3,
    this.resetTimeout = const Duration(seconds: 45),
  });

  final int failureThreshold;
  final Duration resetTimeout;

  final Map<String, _Breaker> _breakers = {};

  CircuitState stateOf(String key) {
    final b = _breakers.putIfAbsent(key, _Breaker.new);
    if (b.state == CircuitState.open &&
        DateTime.now().difference(b.openedAt!) >= resetTimeout) {
      b.state = CircuitState.halfOpen;
    }
    return b.state;
  }

  bool allow(String key) => stateOf(key) != CircuitState.open;

  Duration? retryAfter(String key) {
    final b = _breakers[key];
    if (b == null || b.state != CircuitState.open || b.openedAt == null) {
      return null;
    }
    final remaining = resetTimeout - DateTime.now().difference(b.openedAt!);
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }

  void reset(String key) => _breakers.remove(key);

  void recordSuccess(String key) {
    final b = _breakers.putIfAbsent(key, _Breaker.new);
    b
      ..failures = 0
      ..state = CircuitState.closed
      ..openedAt = null;
  }

  void recordFailure(String key) {
    final b = _breakers.putIfAbsent(key, _Breaker.new);
    b.failures++;
    if (b.failures >= failureThreshold) {
      b
        ..state = CircuitState.open
        ..openedAt = DateTime.now();
    }
  }

  Map<String, String> snapshot() {
    return {
      for (final entry in _breakers.entries) entry.key: entry.value.state.name,
    };
  }
}

class _Breaker {
  CircuitState state = CircuitState.closed;
  int failures = 0;
  DateTime? openedAt;
}
