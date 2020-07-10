import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:nima/nima_actor.dart';

class RepeatAnimController extends FlareController {
  FlareAnimationLayer _rotationAnimation;

  final String animation;

  RepeatAnimController(this.animation);

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    /// Advance the rotation animation every frame.
    _rotationAnimation.time =
        (_rotationAnimation.time + elapsed) % _rotationAnimation.duration;
    _rotationAnimation.apply(artboard);

    return true;
  }

  /// Grab the references to the right animations, and
  /// packs them into [FlareAnimationLayer] objects
  @override
  void initialize(FlutterActorArtboard artboard) {
    _rotationAnimation = FlareAnimationLayer()
      ..animation = artboard.getAnimation(animation)
      ..mix = 1.0;
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}
}
