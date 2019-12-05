import 'spring_config.dart';
import 'spring_system.dart';

class Spring {
  static int __id = 0;
  static double maxDeltaTimeSec = 0.064;
  static double solverTimeStepSec = 0.001;

  Spring({SpringSystem system})
      : _system = system,
        _id = 's${Spring.__id++}';
  // 弹簧系统实例
  final SpringSystem _system;
  // 弹簧Spring对应的ID
  String _id;
  // 弹框的配置
  SpringConfig springConfig;
  // 弹簧是否已经闲置
  bool _wasAtRest = true;
  double displacementFromRestThreshold = 0.001;
  double restSpeedThreshold = 0.001;
  bool overshootClampingEnabled = false;
  double _endValue = 0;
  double _startValue = 0;
  PhysicsState _currentState = PhysicsState();
  PhysicsState _tempState = PhysicsState();
  PhysicsState _previousState = PhysicsState();
  double _timeAccumulator = 0;
  List<SpringListener> _endChangeListeners = [];
  List<SpringListener> _activeListeners = [];
  List<SpringListener> _updateListeners = [];
  List<SpringListener> _restListeners = [];

  String get id => _id;
  bool get wasAtRest => _wasAtRest;
  double get currentValue => _currentState.position;
  bool get isAtRest {
    final absV = _currentState.velocity < 0
        ? -_currentState.velocity
        : _currentState.velocity;
    return absV < restSpeedThreshold &&
        (getDisplacementDistanceForState(_currentState) <=
                displacementFromRestThreshold ||
            springConfig.tension == 0);
  }

  bool get systemShouldAdvance => !wasAtRest || !isAtRest;
  double get startValue => _startValue;
  double get currentDisplacementDistance =>
      getDisplacementDistanceForState(_currentState);
  double get endValue => _endValue;
  double get velocity => _currentState.velocity;
  bool get isOvershooting =>
      springConfig.tension > 0 &&
      ((_startValue < _endValue && currentValue > _endValue) ||
          (_startValue > _endValue && currentValue < _endValue));

  set endValue(double value) {
    if (_endValue == value && isAtRest) {
      return;
    }
    _startValue = currentValue;
    _endValue = value;
    _system.activateSpring(id);
    notifyListeners(_endChangeListeners);
  }

  set velocity(double value) {
    if (value == _currentState.velocity) return;
    _currentState.velocity = velocity;
    _system.activateSpring(id);
  }

  void dispose() {
    this._system.deregisterSpring(this);
    removeAllListener();
  }

  // 移除所有的监听
  void removeAllListener(){
    _activeListeners = [];
    _restListeners = [];
    _endChangeListeners = [];
    _updateListeners = [];
  }

  //更新监听
  notifyListeners(List<SpringListener> listeners) {
    for (int i = 0; i < listeners.length; i++) {
      var listener = listeners[i];
      if (listener != null) listener(this);
    }
  }

  // 使用RK4(四阶龙格库塔方法进行计算)
  advance({double realDeltaTime}) {
    var _isAtRest = isAtRest;
    if (isAtRest && _wasAtRest) {
      return;
    }
    var adjustedDeltaTime = realDeltaTime;
    if (realDeltaTime > Spring.maxDeltaTimeSec) {
      adjustedDeltaTime = Spring.maxDeltaTimeSec;
    }
    _timeAccumulator += adjustedDeltaTime;
    var tension = springConfig.tension;
    var friction = springConfig.friction;
    var position = this._currentState.position;
    var velocity = this._currentState.velocity;
    var tempPosition = this._tempState.position;
    var tempVelocity = this._tempState.velocity;
    var aVelocity;
    var aAcceleration;
    var bVelocity;
    var bAcceleration;
    var cVelocity;
    var cAcceleration;
    var dVelocity;
    var dAcceleration;
    var dxdt;
    var dvdt;

    while (_timeAccumulator >= Spring.solverTimeStepSec) {
      _timeAccumulator -= Spring.solverTimeStepSec;
      if (_timeAccumulator < Spring.solverTimeStepSec) {
        _previousState.position = position;
        _previousState.velocity = velocity;
      }
      aVelocity = velocity;
      aAcceleration =
          tension * (this._endValue - tempPosition) - friction * velocity;

      tempPosition = position + aVelocity * Spring.solverTimeStepSec * 0.5;
      tempVelocity = velocity + aAcceleration * Spring.solverTimeStepSec * 0.5;
      bVelocity = tempVelocity;
      bAcceleration =
          tension * (this._endValue - tempPosition) - friction * tempVelocity;

      tempPosition = position + bVelocity * Spring.solverTimeStepSec * 0.5;
      tempVelocity = velocity + bAcceleration * Spring.solverTimeStepSec * 0.5;
      cVelocity = tempVelocity;
      cAcceleration =
          tension * (this._endValue - tempPosition) - friction * tempVelocity;

      tempPosition = position + cVelocity * Spring.solverTimeStepSec;
      tempVelocity = velocity + cAcceleration * Spring.solverTimeStepSec;
      dVelocity = tempVelocity;
      dAcceleration =
          tension * (this._endValue - tempPosition) - friction * tempVelocity;

      dxdt =
          1.0 / 6.0 * (aVelocity + 2.0 * (bVelocity + cVelocity) + dVelocity);
      dvdt = 1.0 /
          6.0 *
          (aAcceleration +
              2.0 * (bAcceleration + cAcceleration) +
              dAcceleration);

      position += dxdt * Spring.solverTimeStepSec;
      velocity += dvdt * Spring.solverTimeStepSec;
    }

    _tempState.position = tempPosition;
    _tempState.velocity = tempVelocity;

    this._currentState.position = position;
    this._currentState.velocity = velocity;

    if (this._timeAccumulator > 0) {
      this._interpolate(this._timeAccumulator / Spring.solverTimeStepSec);
    }

    if (isAtRest || (overshootClampingEnabled && isOvershooting)) {
      if (springConfig.tension > 0) {
        this._startValue = this._endValue;
        this._currentState.position = this._endValue;
      } else {
        this._endValue = this._currentState.position;
        this._startValue = this._endValue;
      }
      this.velocity = 0;
      _isAtRest = true;
    }

    var notifyActivate = false;
    if (this._wasAtRest) {
      this._wasAtRest = false;
      notifyActivate = true;
    }

    var notifyAtRest = false;
    if (_isAtRest) {
      this._wasAtRest = true;
      notifyAtRest = true;
    }

    this.notifyPositionUpdated(notifyActivate, notifyAtRest);
  }

  // 用于连锁动画
  chain(Spring parent){
    parent.addUpdateListener((spring){
      endValue = spring.currentValue;
    });
  }

  setCurrentValue(double currentValue,{ bool skipSetAtRest = false}) {
    _startValue = currentValue;
    _currentState.position = currentValue;
    if (!skipSetAtRest) {
      setAtRest();
      notifyPositionUpdated(false, false);
    }
  }

  setAtRest() {
    _endValue = _currentState.position;
    _tempState.position = _currentState.position;
    _currentState.velocity = 0;
  }

  // 触发更新
  void notifyPositionUpdated(bool notifyActivate, bool notifyAtRest) {
    if (notifyActivate) notifyListeners(_activeListeners);
    notifyListeners(_updateListeners);
    if (notifyAtRest) notifyListeners(_restListeners);
  }

  double getCurrentDisplacementDistance() {
    return this.getDisplacementDistanceForState(this._currentState);
  }

  double getDisplacementDistanceForState(PhysicsState state) {
    return _endValue > state.position
        ? _endValue - state.position
        : state.position - _endValue;
  }

  _interpolate(num alpha) {
    this._currentState.position = this._currentState.position * alpha +
        this._previousState.position * (1 - alpha);
    this._currentState.velocity = this._currentState.velocity * alpha +
        this._previousState.velocity * (1 - alpha);
  }

  addEndStateChangeListener(SpringListener value) => _endChangeListeners.add(value);
  addActiveListener(SpringListener value) => _activeListeners.add(value);
  addUpdateListener(SpringListener value) => _updateListeners.add(value);
  addAtRestListener(SpringListener value) => _restListeners.add(value);
}

typedef SpringListener = void Function(Spring spring);

class PhysicsState {
  PhysicsState({
    this.position = 0,
    this.velocity = 0,
  });
  double position;
  double velocity;
}

enum SpringStatus {
  atRest,
  active,
  update,
  end,
}
