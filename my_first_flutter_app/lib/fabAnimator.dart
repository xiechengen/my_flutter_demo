import 'package:flutter/material.dart';
import 'dart:math' as math;


class FabAnimator extends FloatingActionButtonAnimator {
  const FabAnimator();

  @override
  Offset getOffset({ Offset begin, Offset end, double progress }) {
  if (progress < 0.5) {
  return begin;
  } else {
  return end;
  }
  }

  @override
  Animation<double> getScaleAnimation({ Animation<double> parent }) {
  // Animate the scale down from 1 to 0 in the first half of the animation
  // then from 0 back to 1 in the second half.
  const Curve curve = Interval(0.5, 1.0, curve: Curves.ease);
  return _AnimationSwap<double>(
  ReverseAnimation(parent.drive(CurveTween(curve: curve.flipped))),
  parent.drive(CurveTween(curve: curve)),
  parent,
  0.5,
  );
  }

  // Because we only see the last half of the rotation tween,
  // it needs to go twice as far.
  static final Animatable<double> _rotationTween = Tween<double>(
  begin: 1.0 - kFloatingActionButtonTurnInterval * 2.0,
  end: 1.0,
  );

  static final Animatable<double> _thresholdCenterTween = CurveTween(curve: const Threshold(0.5));

  @override
  Animation<double> getRotationAnimation({ Animation<double> parent }) {
  // This rotation will turn on the way in, but not on the way out.
  return _AnimationSwap<double>(
  parent.drive(_rotationTween),
  ReverseAnimation(parent.drive(_thresholdCenterTween)),
  parent,
  0.5,
  );
  }

  // If the animation was just starting, we'll continue from where we left off.
  // If the animation was finishing, we'll treat it as if we were starting at that point in reverse.
  // This avoids a size jump during the animation.
  @override
  double getAnimationRestart(double previousValue) => math.min(1.0 - previousValue, previousValue);
  }

/// An animation that swaps from one animation to the next when the [parent] passes [swapThreshold].
///
/// The [value] of this animation is the value of [first] when [parent.value] < [swapThreshold]
/// and the value of [next] otherwise.
class _AnimationSwap<T> extends CompoundAnimation<T> {
  /// Creates an [_AnimationSwap].
  ///
  /// Both arguments must be non-null. Either can be an [_AnimationSwap] itself
  /// to combine multiple animations.
  _AnimationSwap(Animation<T> first, Animation<T> next, this.parent, this.swapThreshold) : super(first: first, next: next);

  final Animation<double> parent;
  final double swapThreshold;

  @override
  T get value => parent.value < swapThreshold ? first.value : next.value;
}

