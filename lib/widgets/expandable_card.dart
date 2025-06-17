import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ExpandableCard extends HookWidget {
  final Widget child;
  final double collapsedHeight;
  final Color? color;
  final double? arrowPadding;

  const ExpandableCard({
    super.key,
    required this.child,
    required this.collapsedHeight,
    this.color,
    this.arrowPadding,
  });

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(duration: 300.ms);
    final isExpanded = useState(false);
    final naturalHeight = useState<double?>(null);
    final measureKey = useMemoized(() => GlobalKey());

    // Measure the natural height of the content
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final RenderBox? renderBox =
            measureKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null && naturalHeight.value == null) {
          naturalHeight.value = renderBox.size.height;
        }
      });
      return null;
    }, []);

    useEffect(() {
      if (naturalHeight.value != null) {
        if (isExpanded.value) {
          animationController.forward();
        } else {
          animationController.reverse();
        }
      }
      return null;
    }, [isExpanded.value, naturalHeight.value]);

    return Stack(
      children: [
        // Invisible widget to measure natural height
        naturalHeight.value == null
            ? Opacity(
                opacity: 0,
                child: Container(key: measureKey, child: child),
              )
            : child
                  .animate(controller: animationController, autoPlay: false)
                  .custom(
                    curve: Curves.easeInOutCirc,
                    duration: 300.ms,
                    begin: collapsedHeight,
                    end: naturalHeight.value!,
                    builder: (context, value, animateChild) {
                      return Container(
                        height: value,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: animateChild,
                        ),
                      );
                    },
                  ),
        Positioned(
          top: arrowPadding ?? 0,
          right: arrowPadding ?? 0,
          child: IconButton(
            icon: Icon(Icons.keyboard_arrow_up)
                .animate(controller: animationController, autoPlay: false)
                .rotate(
                  begin: 0.5,
                  end: 0,
                  curve: Curves.easeInOutCirc,
                  duration: 300.ms,
                ),
            onPressed: () => isExpanded.value = !isExpanded.value,
          ),
        ),
      ],
    );
  }
}
