import 'dart:math';

class BouncyConversion {
  BouncyConversion({this.bounciness, this.speed}) {
    var b = this.normalize(bounciness / 1.7, 0, 20.0);
    b = this.projectNormal(b, 0.0, 0.8);
    final s = this.normalize(speed / 1.7, 0, 20.0);

    this.bouncyTension = this.projectNormal(s, 0.5, 200);
    this.bouncyFriction = this.quadraticOutInterpolation(
      b,
      this.b3Nobounce(this.bouncyTension),
      0.01,
    );
  }

  final num bounciness;
  final num speed;
  num bouncyTension;
  num bouncyFriction;

  num normalize(num value, num startValue, num endValue) =>
      (value - startValue) / (endValue - startValue);

  num projectNormal(num n, num start, num end) => start + n * (end - start);

  num linearInterpolation(t, start, end) => t * end + (1.0 - t) * start;

  num quadraticOutInterpolation(t, start, end) =>
      this.linearInterpolation(2 * t - t * t, start, end);

  num b3Friction1(x) =>
      0.0007 * pow(x, 3) - 0.031 * pow(x, 2) + 0.64 * x + 1.28;

  num b3Friction2(x) => 0.000044 * pow(x, 3) - 0.006 * pow(x, 2) + 0.36 * x + 2;

  num b3Friction3(x) =>
      (0.00000045 * pow(x, 3) - 0.000332 * pow(x, 2) + 0.1078 * x + 5.84);

  num b3Nobounce(tension) {
    var friction = 0;
    if (tension <= 18) {
      friction = this.b3Friction1(tension);
    } else if (tension > 18 && tension <= 44) {
      friction = this.b3Friction2(tension);
    } else {
      friction = this.b3Friction3(tension);
    }
    return friction;
  }
}
