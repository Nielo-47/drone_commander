// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:drone_commander/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:vector_math/vector_math.dart';

class DroneJoystick extends StatelessWidget {
  final DroneController controller;
  const DroneJoystick({Key? key, required this.controller}) : super(key: key);

  Future<void> _commandMovement(StickDragDetails? moveDetails) async {
    controller.setpointVector.xy = Vector2(moveDetails!.x, moveDetails.y);

    controller.setpointVectorNotifier.notifyListeners();

    await controller.move();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: const [
            Icon(Icons.gamepad),
            Text(" Direction"),
          ],
        ),
        Joystick(
          listener: (details) async {
            await _commandMovement(details);
          },
          onStickDragEnd: () async {
            await _commandMovement(StickDragDetails(0, 0));
          },
        ),
      ],
    );
  }
}
