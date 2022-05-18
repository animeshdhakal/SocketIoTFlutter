import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:socketiot/model/device.dart';
import 'package:socketiot/ui/pages/home/device.dart';
import 'package:socketiot/ui/pages/login.dart';
import 'package:socketiot/protocol/protocol.dart';
import 'package:socketiot/protocol/wsclient.dart';
import 'package:socketiot/util/api.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({Key? key}) : super(key: key);

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  List<Device> _devices = [];
  final WebSocketChannel channel = IOWebSocketChannel.connect(
    Api.ws,
  );

  void getDevices() async {
    final response = await api.post("/api/device/all");
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _devices =
            data.map<Device>((dynamic item) => Device.fromJson(item)).toList();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    wsClient.removeEventListener("write");
    wsClient.removeEventListener("authfailed");
    wsClient.removeEventListener("authsuccess");
    wsClient.removeEventListener("status");
  }

  @override
  void initState() {
    super.initState();

    getDevices();

    wsClient.addEventListener("authsuccess", () {
      log("Auth Success");
    });

    wsClient.addEventListener("authfailed", () {
      api.accessToken = null;
      api.expiresIn = null;
      api.refreshToken = null;
      Navigator.of(context).pushReplacementNamed("/login");
    });

    wsClient.addEventListener("status", ({id, status}) {
      setState(() {
        _devices.firstWhere((d) => d.id == num.parse(id)).status = status;
      });
    });

    wsClient.connect(Api.ws, api.accessToken!);

    wsClient.sendMessage(Protocol.sync);

    Timer.periodic(const Duration(milliseconds: Protocol.pingInterval),
        (timer) {
      wsClient.sendMessage(Protocol.ping);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                iconSize: 30,
                icon: const Icon(Icons.logout),
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ));
                },
              ),
            ),
          ],
        ),
        body: GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 2,
          // maxCrossAxisExtent: 200,
          children: List.generate(_devices.length, (index) {
            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DevicePage(
                    device: _devices[index],
                  ),
                ),
              ),
              child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(3, 1), // changes position of shadow
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _devices[index].name!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 15,
                              height: 15,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  color: _devices[index].status == "Online"
                                      ? Colors.green
                                      : Colors.red),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              _devices[index].status!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      )
                    ],
                  )),
            );
          }),
        ));
  }
}
