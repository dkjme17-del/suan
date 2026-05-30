import 'package:flutter/material.dart';

/// Système d'animations réutilisables pour une UX fluide
class AnimationUtils {
  /// Animation fade + slide (entrée élégante)
  static Widget fadeSlideIn({
    required Widget child,
    required AnimationController controller,
    Offset beginOffset = const Offset(0, 0.3),
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: beginOffset, end: Offset.zero)
          .animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic)),
      child: FadeTransition(
        opacity:
            Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInCubic)),
        child: child,
      ),
    );
  }

  /// Animation scale (grow effect)
  static Widget scaleIn({
    required Widget child,
    required AnimationController controller,
    double begin = 0.8,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: begin, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      ),
      child: child,
    );
  }

  /// Animation rotation + fade (fancy entrance)
  static Widget rotateIn({
    required Widget child,
    required AnimationController controller,
  }) {
    return RotationTransition(
      turns: Tween<double>(begin: -0.2, end: 0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      ),
      child: FadeTransition(
        opacity:
            Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInCubic)),
        child: child,
      ),
    );
  }
}

/// Transition fluide personnalisée entre pages
class SlidePageRoute<T> extends PageRoute<T> {
  SlidePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget page;
  final Duration duration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: page,
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;
}

/// Page transition fade + scale
class FadeScalePageRoute<T> extends PageRoute<T> {
  FadeScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
  });

  final Widget page;
  final Duration duration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: page,
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;
}

/// Bouton avec effet ripple + elevation moderne
class ModernButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final double elevation;

  const ModernButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFD97706),
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.elevation = 4,
  }) : super(key: key);

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation =
        Tween<double>(begin: 1, end: 0.95).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withValues(alpha: 0.3),
                blurRadius: widget.elevation * 2,
                offset: Offset(0, widget.elevation),
              ),
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

/// Glassmorphism card premium
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double blur;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.blur = 10,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: blur,
              spreadRadius: 0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Card avec gradient et shadow premium
class GradientCard extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const GradientCard({
    Key? key,
    required this.colors,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Loader animation moderne
class ModernLoader extends StatefulWidget {
  final Color color;
  final double size;

  const ModernLoader({
    Key? key,
    this.color = const Color(0xFFD97706),
    this.size = 40,
  }) : super(key: key);

  @override
  State<ModernLoader> createState() => _ModernLoaderState();
}

class _ModernLoaderState extends State<ModernLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              widget.color,
              widget.color.withValues(alpha: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slide counter avec animation
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle textStyle;

  const AnimatedCounter({
    Key? key,
    required this.value,
    this.duration = const Duration(milliseconds: 600),
    required this.textStyle,
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0);
      _animation = IntTween(begin: oldWidget.value, end: widget.value)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
        return Text(
          _animation.value.toString(),
          style: widget.textStyle,
        );
      },
    );
  }
}

/// Expandable section avec animation fluide
class ExpandableSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final Color titleColor;

  const ExpandableSection({
    Key? key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.titleColor = const Color(0xFFD97706),
  }) : super(key: key);

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (_isExpanded) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleExpand,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.titleColor)),
                RotationTransition(
                  turns: Tween<double>(begin: 0, end: 0.5)
                      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
                  child: Icon(Icons.expand_more, color: widget.titleColor),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
