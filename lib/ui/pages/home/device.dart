import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:socketiot/model/device.dart';
import 'package:socketiot/protocol/protocol.dart';
import 'package:socketiot/protocol/wsclient.dart';
import 'package:socketiot/ui/widget/button.dart';
import 'package:socketiot/util/api.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key, required this.device}) : super(key: key);

  final Device device;

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  List<dynamic> _widgets = [];

  void fetchBlueprint() async {
    print("Value of ExpiresIn is ${api.expiresIn}");

    Response resp = await api
        .post("/api/blueprint/get", body: {"id": widget.device.blueprintId});
    final data = jsonDecode(resp.body);
    setState(() {
      _widgets = data["widgets"];
    });
    wsClient.sendMessage(Protocol.sync, [widget.device.id.toString()]);
  }

  @override
  void initState() {
    super.initState();

    wsClient.addEventListener("write", ({id, pin, value}) {
      if (widget.device.id == num.parse(id)) {
        for (int i = 0; i < _widgets.length; i++) {
          if (_widgets[i]["pin"] == num.parse(pin)) {
            setState(() {
              _widgets[i]["value"] = value;
            });
          }
        }
      }
    });

    fetchBlueprint();
  }

  void setValue(int index, String key, String value) {
    setState(() {
      _widgets[index][key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _widgets.length,
          itemBuilder: (context, index) {
            if (_widgets[index]["type"] == "BUTTON") {
              return Button(
                key: _widgets[index]["token"],
                widgets: _widgets,
                index: index,
                setValue: setValue,
                id: widget.device.id,
              );
            }

            return const Text("NULL");
          },
        ),
      ),
    );
  }
}
