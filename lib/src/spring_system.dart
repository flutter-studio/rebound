import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'spring.dart';
import 'spring_config.dart';

///
class SpringSystem {
  SpringSystem({TickerProviderStateMixin vsync}) {
    _ticker = vsync.createTicker(_tick);
  }
  // 注册的spring
  Map<String, Spring> _springRegistry = {};
  // 激活的spring
  List<Spring> _activeSprings = [];
  // 是否处于闲置状态
  bool _isIdle = true;
  // 用于每帧触发的ticker
  Ticker _ticker;
  // 存放闲置Spring的索引
  List<num> _idleSpringIndices = [];

  Spring createSpring(tension, friction) {
    SpringConfig springConfig;
    if (tension == null || friction == null) {
      springConfig = SpringConfig.defaultOrigamiSpringConfig;
    } else {
      springConfig = SpringConfig.fromOrigamiTensionAndFriction(
        tension,
        friction,
      );
    }
    return this.createSpringWithConfig(springConfig);
  }

  Spring createSpringWithBouncinessAndSpeed(
    bounciness,
    speed,
  ) {
    SpringConfig springConfig;
    if (bounciness == null || speed == null) {
      springConfig = SpringConfig.defaultOrigamiSpringConfig;
    } else {
      springConfig = SpringConfig.fromBouncinessAndSpeed(bounciness, speed);
    }
    return this.createSpringWithConfig(springConfig);
  }

  Spring createSpringWithConfig(SpringConfig config) {
    var spring = Spring(system: this)..springConfig = config;
    registerSpring(spring);
    return spring;
  }

  bool get isIdle => _isIdle;

  getSpringById(String id) => _springRegistry[id];

  List<Spring> getAllSprings() => _springRegistry.values.toList();

  // 注册spring
  void registerSpring(Spring spring) => _springRegistry[spring.id] = spring;

  // 销毁spring
  void deregisterSpring(Spring spring) {
    _springRegistry.remove(spring);
    _activeSprings.remove(Spring);
  }

  // 激活spring
  void activateSpring(String id) {
    final spring = _springRegistry[id];
    if (!_activeSprings.contains(id)) {
      _activeSprings.add(spring);
    }
    if (this.isIdle) {
      _isIdle = false;
      _ticker?.start();
    }
  }

  advance({num deltaTime}) {
    if (_idleSpringIndices.isNotEmpty) _idleSpringIndices.removeLast();
    for (int i = 0; i < _activeSprings.length; i++) {
      final spring = _activeSprings[i];
      if (spring.systemShouldAdvance) {
        spring.advance(realDeltaTime: deltaTime / 1000.0);
      } else {
        _idleSpringIndices.add(_activeSprings.indexOf(spring));
      }
      if (_idleSpringIndices.isNotEmpty) {
        final idx = _idleSpringIndices.removeLast();
        if (idx >= 0) _activeSprings.removeAt(idx);
      }
    }
  }

  void _tick(Duration duration) {
    advance(deltaTime: 16.67);
    if (_activeSprings.isEmpty) {
      this._isIdle = true;
      _ticker?.stop();
    }
  }

  // 移除所有的spring的监听
  void _removeAllSpringListeners() {
    for (int i = 0; i < _activeSprings.length; i++) {
      final spring = _activeSprings[i];
      spring.removeAllListener();
    }
  }

  void dispose() {
    _ticker?.stop(canceled: true);
    _removeAllSpringListeners();
  }
}
