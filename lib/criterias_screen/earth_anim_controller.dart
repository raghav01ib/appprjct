import 'dart:math';
import 'package:nima/nima_actor.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';

import 'repeat_anim_controller.dart';

class EarthAnimController extends RepeatAnimController {
  int _score = 0;
  FlareAnimationLayer _scoreAnimation;

  EarthAnimController() : super('rotation');

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    super.advance(artboard, elapsed);

    // Advance the score animation every frame.
    var destTime = computeDestinationTime();
    if (_scoreAnimation.time != destTime) {
      _scoreAnimation.time = _scoreAnimation.time > destTime
          ? max(destTime, _scoreAnimation.time - elapsed / 2)
          : min(destTime, _scoreAnimation.time + elapsed / 2);
      _scoreAnimation.apply(artboard);
    }

    return true;
  }

  double computeDestinationTime() => min(1, _score / 100);

  /// Grab the references to the right animations, and
  /// packs them into [FlareAnimationLayer] objects
  @override
  void initialize(FlutterActorArtboard artboard) {
    super.initialize(artboard);

    _scoreAnimation = FlareAnimationLayer()
      ..animation = artboard.getAnimation('color_0_to_100')
      ..mix = 1.0
      ..time = computeDestinationTime()
      ..apply(artboard);
  }

  set score(int value) {
    if (_score == value) {
      return;
    }

    _score = min((value * 3).toInt(), 100);
  }

  int get score => _score;
}
