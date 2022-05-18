import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:socketiot/util/api.dart';

class ResetPage extends StatefulWidget {
  const ResetPage({Key? key}) : super(key: key);

  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  void showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    ));
  }

  void showSuccess(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: const Color.fromARGB(255, 123, 217, 126),
      duration: const Duration(seconds: 2),
    ));
  }

  void reset() async {
    String email = _emailController.text;

    if (email.isEmpty) {
      showError("Please enter email");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      showError("Please enter a valid email");
      return;
    }

    setState(() {
      _loading = true;
    });

    final Response response = await api.wpost("/api/user/reset", body: {
      "email": email,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      showSuccess(data["message"]);
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
              "Forgot Password",
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
            height: 25,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () {},
                child: InkWell(
                  onTap: () {
                    if (!_loading) {
                      reset();
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
                      "Send Reset Link",
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
              onTap: (() => Navigator.pushNamed(context, "/login")),
              child: Text(
                "Already Reset?",
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
