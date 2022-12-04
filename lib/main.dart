import 'package:drone_commander/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'widgets/pitch_and_roll.dart';
import 'widgets/lift_and_yaw.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]).then(
    (_) => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drone Commander',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const _CommandControls(),
    );
  }
}

class _CommandControls extends StatelessWidget {
  const _CommandControls();

  @override
  Widget build(BuildContext context) {
    DroneController controller = DroneController();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DroneJoystick(controller: controller),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder<Vector4>(
                    valueListenable: controller.setpointVectorNotifier,
                    builder: (context, coord, _) {
                      return Text(
                        "X: ${coord.x.toStringAsFixed(3)}\n"
                        "Y: ${coord.y.toStringAsFixed(3)}\n"
                        "Z: ${coord.z.toStringAsFixed(3)}\n"
                        "Yaw: ${coord.w.toStringAsFixed(3)}\n",
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  ValueListenableBuilder<List<num>>(
                    valueListenable: controller.motorThrustListNotifier,
                    builder: (context, thrust, _) {
                      return Text(
                        "\nM1: ${thrust[0]}  M2: ${thrust[1]}\n"
                        "M3: ${thrust[2]}  M4: ${thrust[3]}",
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  ValueListenableBuilder<num>(
                    valueListenable: controller.liftCoeffNotifier,
                    builder: (context, liftCoeff, _) {
                      return Text(
                        "\nLift Coeff: ${liftCoeff.toStringAsFixed(3)}",
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
              ),
              LiftAndYaw(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
