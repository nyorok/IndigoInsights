import 'package:flutter/material.dart';
import 'package:indigo_insights/utils/loader.dart';

/// Replaces Riverpod's `.when(data:, loading:, error:)` pattern.
///
/// Pass a [fetcher] factory (not a resolved [Future]) so that [retry] can
/// re-invoke it without needing to rebuild the parent widget.
class AsyncBuilder<T> extends StatefulWidget {
  final Future<T> Function() fetcher;
  final Widget Function(T data) builder;
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;

  const AsyncBuilder({
    super.key,
    required this.fetcher,
    required this.builder,
    this.errorBuilder,
  });

  @override
  State<AsyncBuilder<T>> createState() => _AsyncBuilderState<T>();
}

class _AsyncBuilderState<T> extends State<AsyncBuilder<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.fetcher();
  }

  void _retry() {
    setState(() => _future = widget.fetcher());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        if (snap.hasError) {
          final err = snap.error!;
          return widget.errorBuilder?.call(err, _retry) ??
              Center(child: Text('Error: $err'));
        }
        return widget.builder(snap.data as T);
      },
    );
  }
}
