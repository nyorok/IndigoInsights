import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
      child: ConstrainedBox(
          constraints: const BoxConstraints(
              minHeight: 30, maxHeight: 60, minWidth: 30, maxWidth: 60),
          child: const CircularProgressIndicator(
            color: Colors.white,
          )));
}
