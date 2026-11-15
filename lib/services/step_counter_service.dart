import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

enum SensorStatus {
  unknown,
  available,
  listening,
  unavailable,
  permissionDenied,
}

class StepCounterService {
  static final StepCounterService _instance = StepCounterService._internal();
  factory StepCounterService() => _instance;
  StepCounterService._internal();

  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  SensorStatus _status = SensorStatus.unknown;
  SensorStatus get status => _status;

  int _initialSensorSteps = -1;
  int _currentSensorSteps = 0;
  String _pedestrianStatus = 'Unknown';

  int get currentSensorSteps => _currentSensorSteps;
  String get pedestrianStatus => _pedestrianStatus;

  // Callback to inform listeners when sensor steps update
  Function(int liveSensorSteps)? onStepChanged;
  Function(SensorStatus status)? onStatusChanged;

  Future<void> initialize() async {
    try {
      // Check & request Activity Recognition permission on Android
      final PermissionStatus permStatus =
          await Permission.activityRecognition.request();

      if (permStatus.isGranted) {
        _status = SensorStatus.available;
        _startListening();
      } else {
        _status = SensorStatus.permissionDenied;
        debugPrint('StepCounterService: Activity Recognition permission denied.');
      }
    } catch (e) {
      _status = SensorStatus.unavailable;
      debugPrint('StepCounterService: Sensor initialization error: $e');
    }
    onStatusChanged?.call(_status);
  }

  void _startListening() {
    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        cancelOnError: false,
      );

      _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
        cancelOnError: false,
      );

      _status = SensorStatus.listening;
      onStatusChanged?.call(_status);
    } catch (e) {
      _status = SensorStatus.unavailable;
      onStatusChanged?.call(_status);
      debugPrint('StepCounterService: Error starting pedometer streams: $e');
    }
  }

  void _onStepCount(StepCount event) {
    if (_initialSensorSteps == -1) {
      _initialSensorSteps = event.steps;
    }

    // Relative steps detected during this active session
    final int sessionSteps = event.steps - _initialSensorSteps;
    _currentSensorSteps = sessionSteps > 0 ? sessionSteps : 0;

    onStepChanged?.call(_currentSensorSteps);
  }

  void _onStepCountError(dynamic error) {
    debugPrint('StepCounterService: Pedometer error: $error');
    _status = SensorStatus.unavailable;
    onStatusChanged?.call(_status);
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    _pedestrianStatus = event.status;
  }

  void _onPedestrianStatusError(dynamic error) {
    debugPrint('StepCounterService: Pedestrian status error: $error');
  }

  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
  }
}
