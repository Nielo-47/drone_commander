import 'dart:convert';
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

  final ValueNotifier<String> responseNotifier = ValueNotifier<String>("");
  String get response {
    late Map<String, dynamic> responseMap;

    try {
      responseMap = jsonDecode(responseNotifier.value);
    } catch (e) {
      responseMap = {"Error": responseNotifier.value};
    }

    String responseString = "";
    for (MapEntry entry in responseMap.entries) {
      responseString += "${entry.key}: ${entry.value}°\n";
    }
    return responseString;
  }

  set response(String newResponse) => responseNotifier.value = newResponse;

  Future<void> move() async {
    final List<int> thrusts = _calculateIndividualMotorThrustPercentage();

    String request = "http://$_espIP";

    for (int thrust in thrusts) {
      if (thrust <= 0) {
        request += "/000";
      } else if (thrust >= 100) {
        request += "/100";
      } else {
        request += "/0$thrust";
      }
    }

    response = await http
        .read(
          Uri.parse(
            request,
          ),
        )
        .timeout(
          const Duration(seconds: 2),
          onTimeout: () => "TIMEOUT",
        )
        .onError((error, stackTrace) => error.toString());
  }

  Future<void> getDroneAngles() async {
    String request = "http://$_espIP/read";

    response = await http
        .read(
          Uri.parse(
            request,
          ),
        )
        .timeout(
          const Duration(milliseconds: 500),
          onTimeout: () => "TIMEOUT",
        )
        .onError((error, stackTrace) => error.toString());
  }

  List<int> _calculateIndividualMotorThrustPercentage() {
    final Vector2 pitchRollVector = Vector2(setpointVector.x, setpointVector.y);

    final List<double> motorAnglesToSetPoint = [
      Vector2(-0.5, 0.5).angleTo(pitchRollVector) * 180 / pi,
      Vector2(0.5, 0.5).angleTo(pitchRollVector) * 180 / pi,
      Vector2(-0.5, -0.5).angleTo(pitchRollVector) * 180 / pi,
      Vector2(0.5, -0.5).angleTo(pitchRollVector) * 180 / pi,
    ];

    _calculateLiftCoeff();

    const maxMovePercent = 25;
    const maxLiftPercent = 100;
    final liftPercent = maxLiftPercent * liftCoeff;

    List<int> thrustsPercent = motorAnglesToSetPoint
        .map((e) => (liftPercent -
                e.remapAndClamp(
                        45, 135, 0, liftPercent < 50 ? 0 : maxMovePercent) *
                    pitchRollVector.length)
            .toInt())
        .toList();

    motorThrustListNotifier.value = thrustsPercent;

    return thrustsPercent;
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
