import 'package:flutter/material.dart';

// Standard animation durations
const Duration kAnimationFast = Duration(milliseconds: 200);
const Duration kAnimationStandard = Duration(milliseconds: 300);
const Duration kAnimationSlow = Duration(milliseconds: 500);
const Duration kAnimationExtraSlow = Duration(milliseconds: 800);

// Staggered list animation - cascade entrance effect
class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Axis scrollDirection;

  const StaggeredListAnimation({
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.scrollDirection = Axis.vertical,
    super.key,
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List<AnimationController>.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: kAnimationStandard,
        vsync: this,
      ),
    );

    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(
        widget.staggerDelay * i,
        () {
          if (mounted) {
            _controllers[i].forward();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.scrollDirection == Axis.vertical
        ? Column(
            children: [
              for (int i = 0; i < widget.children.length; i++)
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controllers[i],
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _controllers[i],
                    child: widget.children[i],
                  ),
                ),
            ],
          )
        : Row(
            children: [
              for (int i = 0; i < widget.children.length; i++)
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-0.2, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controllers[i],
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _controllers[i],
                    child: widget.children[i],
                  ),
                ),
            ],
          );
  }
}

// Scale in animation - smooth entrance with fade
class ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double beginScale;

  const ScaleInAnimation({
    required this.child,
    this.duration = kAnimationStandard,
    this.curve = Curves.easeOutBack,
    this.beginScale = 0.8,
    super.key,
  });

  @override
  State<ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<ScaleInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: widget.beginScale, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}

// Slide in animation - directional slide with fade
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset beginOffset;

  const SlideInAnimation({
    required this.child,
    this.duration = kAnimationStandard,
    this.curve = Curves.easeOutCubic,
    this.beginOffset = const Offset(0, 0.3),
    super.key,
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _slideAnimation = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _controller, child: widget.child),
    );
  }
}

// Number counter animation - animated number transitions
class NumberCounterAnimation extends StatefulWidget {
  final int endValue;
  final Duration duration;
  final TextStyle? textStyle;
  final String suffix;

  const NumberCounterAnimation({
    required this.endValue,
    this.duration = kAnimationSlow,
    this.textStyle,
    this.suffix = '',
    super.key,
  });

  @override
  State<NumberCounterAnimation> createState() => _NumberCounterAnimationState();
}

class _NumberCounterAnimationState extends State<NumberCounterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = IntTween(begin: 0, end: widget.endValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${_animation.value}${widget.suffix}',
          style: widget.textStyle,
        );
      },
    );
  }
}

// Progress bar animation - smooth progress value changes
class ProgressBarAnimation extends StatefulWidget {
  final double value;
  final Duration duration;
  final double minHeight;
  final Color backgroundColor;
  final Color valueColor;

  const ProgressBarAnimation({
    required this.value,
    this.duration = kAnimationStandard,
    this.minHeight = 8,
    required this.backgroundColor,
    required this.valueColor,
    super.key,
  });

  @override
  State<ProgressBarAnimation> createState() => _ProgressBarAnimationState();
}

class _ProgressBarAnimationState extends State<ProgressBarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressBarAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value)
          .animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: _animation.value.clamp(0.0, 1.0),
            minHeight: widget.minHeight,
            backgroundColor: widget.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(widget.valueColor),
          ),
        );
      },
    );
  }
}

// Pulse animation - looping scale pulse effect
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    super.key,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
