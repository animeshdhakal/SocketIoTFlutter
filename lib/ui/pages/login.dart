import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:socketiot/util/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  void showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    ));
  }

  void login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showError("Please enter email and password");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      showError("Please enter a valid email");
      return;
    }

    if (password.length < 5) {
      showError("Password must be at least 5 characters");
      return;
    }

    setState(() {
      _loading = true;
    });

    final navigator = Navigator.of(context);

    final Response response = await api.wpost("/api/user/login", body: {
      "email": email,
      "password": password,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      api.accessToken = data["access_token"];
      api.refreshToken = data["refresh_token"];
      api.expiresIn =
          (DateTime.now().millisecondsSinceEpoch + data["expires_in"]).toInt();

      navigator.pushReplacementNamed("/home/devices");
    } else {
      showError(data["message"]);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              "SocketIoT",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          const Center(
            child: Text(
              "Login",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.only(left: 20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Colors.white,
              ),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: "Email"),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.only(left: 20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
              child: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: "Password"),
                obscureText: true,
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () {},
                child: InkWell(
                  onTap: () {
                    if (!_loading) {
                      login();
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: _loading
                            ? const Color.fromARGB(255, 80, 204, 150)
                            : const Color.fromARGB(255, 7, 255, 147)),
                    child: Center(
                        child: Text(
                      "Login",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color:
                              _loading ? Colors.grey[700] : Colors.grey[900]),
                    )),
                  ),
                ),
              )),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: GestureDetector(
              onTap: (() => Navigator.pushReplacementNamed(context, "/reset")),
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/register");
              },
              child: Text(
                "Don't have a account?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
