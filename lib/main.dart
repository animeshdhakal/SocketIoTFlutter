import 'package:flutter/material.dart';
import 'package:socketiot/ui/pages/home/devices.dart';
import 'package:socketiot/ui/pages/login.dart';
import 'package:socketiot/ui/pages/register.dart';
import 'package:socketiot/ui/pages/reset.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/reset": (context) => const ResetPage(),
        "/home/devices": (context) => const DevicesPage(),
      },
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey[200],
          appBarTheme:
              AppBarTheme(backgroundColor: Colors.grey[200], elevation: 0)),
    );
  }
}
