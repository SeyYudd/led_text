import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:led_text/models/state_cubit.dart';
import 'package:led_text/views/home_view.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  runApp(const LEDTextApp());
}

class LEDTextApp extends StatelessWidget {
  const LEDTextApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Led Teks Konser',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: BlocProvider(
        create: (context) => LEDTextCubit(),
        child: LEDTextScreen(),
      ),
    );
  }
}
