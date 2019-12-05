import 'origami_value_converter.dart';
import 'bounce_conversion.dart';

class SpringConfig {
  SpringConfig({this.friction, this.tension});
  final num friction;
  final num tension;

  static final defaultOrigamiSpringConfig =
      SpringConfig.fromOrigamiTensionAndFriction(
    40,
    7,
  );

  SpringConfig.fromOrigamiTensionAndFriction(
    tension,
    friction,
  ) : this(
          tension: tensionFromOrigamiValue(tension),
          friction: frictionFromOrigamiValue(friction),
        );

  SpringConfig.fromBouncinessAndSpeed(
    bounciness,
    speed,
  ) : this.fromOrigamiTensionAndFriction(
          BouncyConversion(bounciness: bounciness, speed: speed).bouncyTension,
          BouncyConversion(bounciness: bounciness, speed: speed).bouncyFriction,
        );

  SpringConfig.coastingConfigWithOrigamiFriction(friction)
      : this(
          tension: 0,
          friction: frictionFromOrigamiValue(friction),
        );
}
