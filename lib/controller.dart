import 'dart:math';

import 'package:num_remap/num_remap.dart';
import 'package:flutter/cupertino.dart';
import 'package:vector_math/vector_math.dart';

import 'package:http/http.dart' as http;

class DroneController {
  static const String _espIP = "192.168.4.1";
  final ValueNotifier<Vector4> setpointVectorNotifier =
      ValueNotifier<Vector4>(Vector4.zero());
  set setpointVector(Vector4 newVector) =>
      setpointVectorNotifier.value = newVector;
  Vector4 get setpointVector => setpointVectorNotifier.value;

  final ValueNotifier<List<num>> motorThrustListNotifier =
      ValueNotifier<List<num>>(List<num>.filled(4, 0));

  final ValueNotifier<double> liftCoeffNotifier = ValueNotifier<double>(0);
  double get liftCoeff => liftCoeffNotifier.value;
  set liftCoeff(double coeff) => liftCoeffNotifier.value = coeff;

  Future<void> move() async {
    final List<int> thrusts = _calculateIndividualMotorThrustPercentage();

    String response = await http.read(
      Uri.parse(
        "http://$_espIP/${thrusts[0]}/${thrusts[1]}/${thrusts[2]}/${thrusts[3]}",
      ),
    );

    debugPrint(response);
  }

  List<int> _calculateIndividualMotorThrustPercentage() {
    final Vector2 pitchRollVector = Vector2(setpointVector.x, setpointVector.y);

    List<double> motorAnglesToSetPoint = [
      Vector2(-0.5, -0.5).angleTo(pitchRollVector) * 180 / pi,
      Vector2(0.5, -0.5).angleTo(pitchRollVector) * 180 / pi,
      Vector2(-0.5, 0.5).angleTo(pitchRollVector) * 180 / pi,
      Vector2(0.5, 0.5).angleTo(pitchRollVector) * 180 / pi,
    ];

    _calculateLiftCoeff();

    final minLiftPercent = 70 * liftCoeff;

    List<num> thrustsPercent = motorAnglesToSetPoint
        .map((e) => (e.remapAndClamp(45, 135, 0, minLiftPercent < 30 ? 0 : 20) *
                    pitchRollVector.length +
                70 * liftCoeff)
            .toInt())
        .toList();

    motorThrustListNotifier.value = thrustsPercent;

    return <int>[];
  }

  void _calculateLiftCoeff() {
    double liftCoeff = liftCoeffNotifier.value + setpointVector.z / 10;
    if (liftCoeff < 0) {
      liftCoeff = 0;
    } else if (liftCoeff > 1) {
      liftCoeff = 1;
    }
    liftCoeffNotifier.value = liftCoeff;
  }
}

enum Command { move, stop }
