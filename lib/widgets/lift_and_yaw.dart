// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:drone_commander/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:vector_math/vector_math.dart';

class LiftAndYaw extends StatelessWidget {
  final DroneController controller;
  const LiftAndYaw({super.key, required this.controller});

  Future<void> _commandMovement(StickDragDetails? moveDetails) async {
    controller.setpointVector.zw = Vector2(-moveDetails!.y, moveDetails.x);

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
            Icon(Icons.remove_circle_outline),
            Text(" Yaw"),
            Text(" | "),
            RotatedBox(
              quarterTurns: 1,
              child: Icon(Icons.remove_circle_outline),
            ),
            Text(" Thrust"),
          ],
        ),
        Joystick(
          mode: JoystickMode.horizontalAndVertical,
          listener: (details) async {
            _commandMovement(details);
          },
          onStickDragEnd: () {
            _commandMovement(StickDragDetails(0, 0));
          },
        ),
      ],
    );
  }
}
