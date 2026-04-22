// ignore_for_file: library_private_types_in_public_api, document_ignores, lines_longer_than_80_chars, public_member_api_docs

import 'package:flutter/material.dart';

enum GoodDismissableSwipeBehavior { dismiss, reveal }

/// A customizable swipe card widget that mimics Gmail iOS style dismissible behavior
/// with a background card that appears behind the main card during swipe gesture
class GoodDismissable extends StatefulWidget {
  const GoodDismissable({
    required this.child,
    super.key,

    this.backgroundContent,
    this.actionContent,
    this.onDismissed,
    this.onActionPressed,
    this.onSwipeProgress,
    this.backgroundColor = Colors.red,
    this.cardOffset = 8.0,
    this.initialScale = 0.95,
    this.initialOpacity = 0.3,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutCubic,
    this.borderRadius = 12.0,
    this.backgroundElevation = 2.0,
    this.mainCardElevation = 4.0,
    this.dismissible = true,
    this.enableSwipeToLeft = true,
    this.enableSwipeToRight = true,
    this.swipeBehavior = GoodDismissableSwipeBehavior.dismiss,
    this.dismissDirections = const {
      DismissDirection.startToEnd,
      DismissDirection.endToStart,
    },
    this.dismissThreshold = 0.4,
    this.revealActionExtent = 96.0,
    this.revealOpenThreshold = 0.5,
    this.closeOnActionTap = true,
    this.margin,
  });

  /// The main content widget that will be displayed and can be swiped
  final Widget child;

  /// Custom widget to display as background when swiping
  /// If null, a default delete icon will be shown
  final Widget? backgroundContent;

  /// Content shown inside the action button when using reveal swipe behavior.
  final Widget? actionContent;

  /// Callback function called when the card is dismissed
  final VoidCallback? onDismissed;

  /// Callback function called when the revealed action is tapped.
  /// Falls back to [onDismissed] when null.
  final VoidCallback? onActionPressed;

  /// Callback function called during swipe with progress value (0.0 to 1.0)
  final ValueChanged<double>? onSwipeProgress;

  /// Background color of the card that appears behind during swipe
  final Color backgroundColor;

  /// Horizontal offset distance for the background card
  final double cardOffset;

  /// Initial scale factor for the background card (0.0 to 1.0)
  final double initialScale;

  /// Initial opacity for the background card (0.0 to 1.0)
  final double initialOpacity;

  /// Duration for the swipe animation
  final Duration animationDuration;

  /// Animation curve for the swipe effect
  final Curve animationCurve;

  /// Border radius for both cards
  final double borderRadius;

  /// Elevation for the background card
  final double backgroundElevation;

  /// Elevation for the main card
  final double mainCardElevation;

  /// Whether to enable swipe to dismiss functionality
  final bool dismissible;

  /// Whether the card can be swiped toward the physical left side.
  final bool enableSwipeToLeft;

  /// Whether the card can be swiped toward the physical right side.
  final bool enableSwipeToRight;

  /// Determines whether swipe should dismiss immediately or reveal a tappable action.
  final GoodDismissableSwipeBehavior swipeBehavior;

  /// Direction(s) allowed for dismissing
  final Set<DismissDirection> dismissDirections;

  /// Threshold for triggering dismiss (0.0 to 1.0)
  final double dismissThreshold;

  /// Width of the revealed action button.
  final double revealActionExtent;

  /// Drag progress needed to keep the action pane open after release.
  final double revealOpenThreshold;

  /// Whether the action pane should close after the action is tapped.
  final bool closeOnActionTap;

  /// Margin around the entire card widget
  final EdgeInsetsGeometry? margin;

  @override
  _GoodDismissableState createState() => _GoodDismissableState();
}

class _GoodDismissableState extends State<GoodDismissable>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _revealOffsetController;
  late Animation<double> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _revealOffsetController = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        if (mounted &&
            widget.swipeBehavior == GoodDismissableSwipeBehavior.reveal) {
          setState(() {});
          _notifyRevealSwipeProgress();
        }
      });
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _offsetAnimation =
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: widget.animationCurve,
          ),
        );

    _scaleAnimation =
        Tween<double>(
          begin: widget.initialScale,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: widget.animationCurve,
          ),
        );

    _opacityAnimation =
        Tween<double>(
          begin: widget.initialOpacity,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: widget.animationCurve,
          ),
        );
  }

  @override
  void didUpdateWidget(GoodDismissable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration ||
        oldWidget.animationCurve != widget.animationCurve ||
        oldWidget.initialScale != widget.initialScale ||
        oldWidget.initialOpacity != widget.initialOpacity) {
      _controller.dispose();
      _initializeAnimations();
    }

    if (widget.swipeBehavior == GoodDismissableSwipeBehavior.reveal) {
      final currentOffset = _revealOffsetController.value;
      final clampedOffset = currentOffset.clamp(
        -widget.revealActionExtent,
        widget.revealActionExtent,
      );

      if (currentOffset != clampedOffset) {
        _revealOffsetController.value = clampedOffset.toDouble();
      }
    } else if (_revealOffsetController.value != 0) {
      _revealOffsetController.value = 0;
    }
  }

  @override
  void dispose() {
    _revealOffsetController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBackgroundContent() {
    return widget.backgroundContent ??
        Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 24,
          ),
        );
  }

  Widget _buildActionContent() {
    return widget.actionContent ??
        widget.backgroundContent ??
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 26,
            ),
            SizedBox(height: 6),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        );
  }

  Widget _buildBackgroundCard() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: Transform.translate(
            offset: Offset(
              widget.cardOffset * (1 - _offsetAnimation.value),
              0,
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Card(
                  elevation: widget.backgroundElevation,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  color: widget.backgroundColor,
                  child: _buildBackgroundContent(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Set<DismissDirection> _resolvedDismissDirections(BuildContext context) {
    final textDirection = Directionality.of(context);
    final leftDirection = textDirection == TextDirection.ltr
        ? DismissDirection.endToStart
        : DismissDirection.startToEnd;
    final rightDirection = textDirection == TextDirection.ltr
        ? DismissDirection.startToEnd
        : DismissDirection.endToStart;

    final allowedDirections = <DismissDirection>{};

    for (final direction in widget.dismissDirections) {
      if (direction == DismissDirection.horizontal) {
        allowedDirections
          ..add(DismissDirection.startToEnd)
          ..add(DismissDirection.endToStart);
        continue;
      }

      if (direction == DismissDirection.startToEnd ||
          direction == DismissDirection.endToStart) {
        allowedDirections.add(direction);
      }
    }

    if (!widget.enableSwipeToLeft) {
      allowedDirections.remove(leftDirection);
    }

    if (!widget.enableSwipeToRight) {
      allowedDirections.remove(rightDirection);
    }

    return allowedDirections;
  }

  DismissDirection _leftDismissDirection(BuildContext context) {
    return Directionality.of(context) == TextDirection.ltr
        ? DismissDirection.endToStart
        : DismissDirection.startToEnd;
  }

  DismissDirection _rightDismissDirection(BuildContext context) {
    return Directionality.of(context) == TextDirection.ltr
        ? DismissDirection.startToEnd
        : DismissDirection.endToStart;
  }

  Widget _buildCardChild() {
    return Card(
      elevation: widget.mainCardElevation,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: widget.child,
    );
  }

  void _notifyRevealSwipeProgress() {
    if (widget.revealActionExtent <= 0) {
      widget.onSwipeProgress?.call(0);
      return;
    }

    final progress =
        (_revealOffsetController.value.abs() / widget.revealActionExtent).clamp(
          0.0,
          1.0,
        );
    widget.onSwipeProgress?.call(progress);
  }

  double _minRevealOffset(Set<DismissDirection> dismissDirections) {
    return dismissDirections.contains(_leftDismissDirection(context))
        ? -widget.revealActionExtent
        : 0;
  }

  double _maxRevealOffset(Set<DismissDirection> dismissDirections) {
    return dismissDirections.contains(_rightDismissDirection(context))
        ? widget.revealActionExtent
        : 0;
  }

  void _animateRevealTo(double targetOffset) {
    _revealOffsetController.animateTo(
      targetOffset,
      duration: widget.animationDuration,
      curve: widget.animationCurve,
    );
  }

  void _handleRevealDragStart() {
    _revealOffsetController.stop();
  }

  void _handleRevealDragUpdate(
    DragUpdateDetails details,
    Set<DismissDirection> dismissDirections,
  ) {
    final nextOffset =
        _revealOffsetController.value + (details.primaryDelta ?? 0);

    _revealOffsetController.value = nextOffset.clamp(
      _minRevealOffset(dismissDirections),
      _maxRevealOffset(dismissDirections),
    );
  }

  void _handleRevealDragEnd(
    DragEndDetails details,
    Set<DismissDirection> dismissDirections,
  ) {
    final velocity = details.primaryVelocity ?? 0;
    final currentOffset = _revealOffsetController.value;
    final openThreshold =
        widget.revealActionExtent * widget.revealOpenThreshold;
    double targetOffset = 0;

    if (velocity.abs() > 250) {
      if (velocity < 0 &&
          dismissDirections.contains(_leftDismissDirection(context))) {
        targetOffset = -widget.revealActionExtent;
      } else if (velocity > 0 &&
          dismissDirections.contains(_rightDismissDirection(context))) {
        targetOffset = widget.revealActionExtent;
      }
    } else if (currentOffset.abs() >= openThreshold) {
      targetOffset = currentOffset.isNegative
          ? _minRevealOffset(dismissDirections)
          : _maxRevealOffset(dismissDirections);
    }

    _animateRevealTo(targetOffset);
  }

  DismissDirection? _currentRevealDirection(
    Set<DismissDirection> dismissDirections,
  ) {
    final currentOffset = _revealOffsetController.value;

    if (currentOffset < 0) {
      return _leftDismissDirection(context);
    }

    if (currentOffset > 0) {
      return _rightDismissDirection(context);
    }

    if (dismissDirections.length == 1) {
      return dismissDirections.first;
    }

    return null;
  }

  void _handleActionTap() {
    final callback = widget.onActionPressed ?? widget.onDismissed;
    callback?.call();

    if (mounted && widget.closeOnActionTap) {
      _animateRevealTo(0);
    }
  }

  Widget _buildRevealActionPane(Set<DismissDirection> dismissDirections) {
    final activeDirection = _currentRevealDirection(dismissDirections);
    if (activeDirection == null) {
      return const SizedBox.shrink();
    }

    final isRightAligned = activeDirection == _leftDismissDirection(context);

    return Positioned.fill(
      child: Align(
        alignment: isRightAligned
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: SizedBox(
          width: widget.revealActionExtent,
          child: Material(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            elevation: widget.backgroundElevation,
            child: InkWell(
              onTap: _handleActionTap,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: _buildActionContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleCard(Set<DismissDirection> dismissDirections) {
    if (!widget.dismissible || dismissDirections.isEmpty) {
      return _buildCardChild();
    }

    return Dismissible(
      key: UniqueKey(),
      background: Container(),
      secondaryBackground: Container(),
      direction: dismissDirections.length == 1
          ? dismissDirections.first
          : DismissDirection.horizontal,
      dismissThresholds: {
        for (final direction in dismissDirections)
          direction: widget.dismissThreshold,
      },
      onUpdate: (details) {
        final progress = details.progress.clamp(0.0, 1.0);
        _controller.value = progress;
        widget.onSwipeProgress?.call(progress);
      },
      onDismissed: (direction) {
        widget.onDismissed?.call();
      },
      child: _buildCardChild(),
    );
  }

  Widget _buildRevealCard(Set<DismissDirection> dismissDirections) {
    if (!widget.dismissible || dismissDirections.isEmpty) {
      return _buildCardChild();
    }

    return GestureDetector(
      onHorizontalDragStart: (_) => _handleRevealDragStart(),
      onHorizontalDragUpdate: (details) =>
          _handleRevealDragUpdate(details, dismissDirections),
      onHorizontalDragEnd: (details) =>
          _handleRevealDragEnd(details, dismissDirections),
      child: Transform.translate(
        offset: Offset(_revealOffsetController.value, 0),
        child: _buildCardChild(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dismissDirections = _resolvedDismissDirections(context);
    final showBackground = widget.dismissible && dismissDirections.isNotEmpty;

    return Container(
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (showBackground &&
              widget.swipeBehavior == GoodDismissableSwipeBehavior.dismiss)
            _buildBackgroundCard(),
          if (showBackground &&
              widget.swipeBehavior == GoodDismissableSwipeBehavior.reveal)
            _buildRevealActionPane(dismissDirections),
          if (widget.swipeBehavior == GoodDismissableSwipeBehavior.reveal)
            _buildRevealCard(dismissDirections)
          else
            _buildDismissibleCard(dismissDirections),
        ],
      ),
    );
  }
}

/// Pre-configured GoodDismissable variants for common use cases
class GoodDismissableVariants {
  /// Gmail-style delete card with red background
  static GoodDismissable delete({
    required Widget child,
    Key? key,
    VoidCallback? onDismissed,
    VoidCallback? onActionPressed,
    ValueChanged<double>? onSwipeProgress,
    bool enableSwipeToLeft = true,
    bool enableSwipeToRight = true,
    GoodDismissableSwipeBehavior swipeBehavior =
        GoodDismissableSwipeBehavior.dismiss,
    double revealActionExtent = 104.0,
  }) {
    return GoodDismissable(
      key: key,
      onDismissed: onDismissed,
      onActionPressed: onActionPressed,
      onSwipeProgress: onSwipeProgress,
      enableSwipeToLeft: enableSwipeToLeft,
      enableSwipeToRight: enableSwipeToRight,
      swipeBehavior: swipeBehavior,
      revealActionExtent: revealActionExtent,
      actionContent: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(height: 6),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
      backgroundContent: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Archive-style card with blue background
  static GoodDismissable archive({
    required Widget child,
    Key? key,
    VoidCallback? onDismissed,
    VoidCallback? onActionPressed,
    ValueChanged<double>? onSwipeProgress,
    bool enableSwipeToLeft = true,
    bool enableSwipeToRight = true,
    GoodDismissableSwipeBehavior swipeBehavior =
        GoodDismissableSwipeBehavior.dismiss,
    double revealActionExtent = 104.0,
  }) {
    return GoodDismissable(
      key: key,
      onDismissed: onDismissed,
      onActionPressed: onActionPressed,
      onSwipeProgress: onSwipeProgress,
      enableSwipeToLeft: enableSwipeToLeft,
      enableSwipeToRight: enableSwipeToRight,
      swipeBehavior: swipeBehavior,
      revealActionExtent: revealActionExtent,
      backgroundColor: Colors.blue,
      actionContent: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive_outlined,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(height: 6),
          Text(
            'Archive',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
      backgroundContent: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Text(
                'Archive',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.archive,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Mark as read card with green background
  static GoodDismissable markRead({
    required Widget child,
    Key? key,
    VoidCallback? onDismissed,
    VoidCallback? onActionPressed,
    ValueChanged<double>? onSwipeProgress,
    bool enableSwipeToLeft = true,
    bool enableSwipeToRight = true,
    GoodDismissableSwipeBehavior swipeBehavior =
        GoodDismissableSwipeBehavior.dismiss,
    double revealActionExtent = 104.0,
  }) {
    return GoodDismissable(
      key: key,
      onDismissed: onDismissed,
      onActionPressed: onActionPressed,
      onSwipeProgress: onSwipeProgress,
      enableSwipeToLeft: enableSwipeToLeft,
      enableSwipeToRight: enableSwipeToRight,
      swipeBehavior: swipeBehavior,
      revealActionExtent: revealActionExtent,
      backgroundColor: Colors.green,
      actionContent: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(height: 6),
          Text(
            'Mark Read',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
      backgroundContent: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Text(
                'Mark Read',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.mark_email_read,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
      child: child,
    );
  }

  /// LinkedIn-style delete action that snaps open and keeps the action tappable.
  static GoodDismissable linkedInDelete({
    required Widget child,
    Key? key,
    VoidCallback? onActionPressed,
    ValueChanged<double>? onSwipeProgress,
    bool enableSwipeToLeft = true,
    bool enableSwipeToRight = false,
    double revealActionExtent = 108.0,
  }) {
    return GoodDismissable(
      key: key,
      onActionPressed: onActionPressed,
      onSwipeProgress: onSwipeProgress,
      enableSwipeToLeft: enableSwipeToLeft,
      enableSwipeToRight: enableSwipeToRight,
      swipeBehavior: GoodDismissableSwipeBehavior.reveal,
      revealActionExtent: revealActionExtent,
      backgroundColor: const Color(0xFFD11124),
      actionContent: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(height: 6),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}
