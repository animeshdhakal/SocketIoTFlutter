import 'package:flutter/material.dart';
import 'package:socketiot/protocol/protocol.dart';
import 'package:socketiot/protocol/wsclient.dart';

class Button extends StatefulWidget {
  final List<dynamic>? widgets;
  final int? index;
  final Function setValue;
  final num? id;

  const Button(
      {Key? key,
      required this.widgets,
      required this.id,
      required this.index,
      required this.setValue})
      : super(key: key);

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        wsClient.sendMessage(Protocol.write, [
          widget.id.toString(),
          widget.widgets![widget.index!]["pin"].toString(),
          widget.widgets![widget.index!]["value"] ==
                  widget.widgets![widget.index!]["onValue"]
              ? widget.widgets![widget.index!]["offValue"]
              : widget.widgets![widget.index!]["onValue"]
        ]);
        widget.setValue(
            widget.index!,
            "value",
            widget.widgets![widget.index!]["value"] ==
                    widget.widgets![widget.index!]["onValue"]
                ? widget.widgets![widget.index!]["offValue"]
                : widget.widgets![widget.index!]["onValue"]);
      },
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 90),
          child: Container(
            margin: const EdgeInsets.all(10),
            height: 120,
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                alignment: Alignment.center,
                width: 240,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(50)),
                child: Text(
                    widget.widgets![widget.index!]["value"] ==
                            widget.widgets![widget.index!]["onValue"]
                        ? widget.widgets![widget.index!]["offLabel"]
                        : widget.widgets![widget.index!]["onLabel"],
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
          )),
    );
  }
}
