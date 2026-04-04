import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExpandableCard extends StatefulWidget {
  final Widget child;
  final double collapsedHeight;
  final bool? startExpanded;
  final Color? color;
  final double? arrowPadding;

  const ExpandableCard({
    super.key,
    required this.child,
    required this.collapsedHeight,
    this.startExpanded = false,
    this.color,
    this.arrowPadding,
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late bool _isExpanded;
  double? _naturalHeight;
  final GlobalKey _measureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.startExpanded ?? false;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Rebuild when animation settles so we can remove the height clip
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _measureKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && _naturalHeight == null) {
        setState(() => _naturalHeight = renderBox.size.height);
        if (_isExpanded) _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_naturalHeight != null) {
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _naturalHeight == null
            ? Opacity(
                opacity: 0,
                child: Container(key: _measureKey, child: widget.child),
              )
            // Fully expanded & animation done → no height constraint, no clip
            : (_isExpanded && _animationController.isCompleted)
                ? widget.child
                : widget.child
                      .animate(
                        controller: _animationController,
                        autoPlay: false,
                      )
                      .custom(
                        curve: Curves.easeInOutCirc,
                        duration: const Duration(milliseconds: 300),
                        begin: widget.collapsedHeight,
                        end: _naturalHeight!,
                        builder: (context, value, animateChild) {
                          return SizedBox(
                            height: value,
                            child: ClipRect(
                              child: OverflowBox(
                                maxHeight: double.infinity,
                                alignment: Alignment.topCenter,
                                child: animateChild,
                              ),
                            ),
                          );
                        },
                      ),
        Positioned(
          top: widget.arrowPadding ?? 0,
          right: widget.arrowPadding ?? 0,
          child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_up)
                .animate(
                  controller: _animationController,
                  autoPlay: false,
                )
                .rotate(
                  begin: 0.5,
                  end: 0,
                  curve: Curves.easeInOutCirc,
                  duration: const Duration(milliseconds: 300),
                ),
            onPressed: _toggle,
          ),
        ),
      ],
    );
  }
}
