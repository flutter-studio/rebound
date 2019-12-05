num tensionFromOrigamiValue(oValue) => (oValue - 30.0) * 3.62 + 194.0;

num origamiValueFromTension(tension) => (tension - 194.0) / 3.62 + 30.0;

num frictionFromOrigamiValue(oValue) => (oValue - 8.0) * 3.0 + 25.0;

num origamiFromFriction(friction) => (friction - 25.0) / 3.0 + 8.0;
