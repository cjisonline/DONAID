import 'package:bubble/bubble.dart';
import 'package:donaid/Widgets/rectDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const styleSender = BubbleStyle(
    margin: BubbleEdges.only(top: 15),
    alignment: Alignment.topRight,
    nip: BubbleNip.rightTop,
    color: Color.fromRGBO(30, 144, 255, 10),
    showNip: false);

const styleReciver = BubbleStyle(
    margin: BubbleEdges.only(top: 15),
    alignment: Alignment.topLeft,
    nip: BubbleNip.leftTop,
    color: Color.fromRGBO(105, 105, 105, 10));

Widget receiverBubble(message, time, isWheel, context) {
  return Padding(
    padding: EdgeInsets.only(right: Get.width / 5),
    child: Bubble(
        style: styleReciver,
        child: Container(
            child: isWheel
                ? InkWell(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                            return Container(
                                decoration: BoxDecoration(
                                    color: Colors.blue.shade400,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30)),
                                    border: Border.all(
                                        color: Colors.blue.shade600,
                                        width: 3.0)),
                                child: ListView(children: [
                                  SizedBox(height: 15),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      // children: [circleMsg(message)]
                                      ),
                                  SizedBox(height: 15),
                                  recDetail(message.split("|")[0]),
                                  SizedBox(height: 15)
                                ]));
                          });
                    },
                    child: Column(children: [
                      if (message.split(":")[2] != "")
                        Row(children: [
                          Expanded(
                              child: Text(message.split(":")[2],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)))
                        ]),
                      if (message.split(":")[2] != "") SizedBox(height: 5),
                     
                      SizedBox(height: 5)
                    ]))
                : Text(message,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.white, fontSize: 18)))),
  );
}

Widget senderBubble(message, time, isWheel, context) {
  return Padding(
    padding: EdgeInsets.only(right: 9.0, left: Get.width / 5),
    child: Bubble(
        style: styleSender,
        child: Container(
            child: isWheel
                ? InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                            return Container(
                                decoration: BoxDecoration(
                                    color: Colors.blue.shade400,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30)),
                                    border: Border.all(
                                        color: Colors.blue.shade600,
                                        width: 3.0)),
                                child: ListView(children: [
                                  SizedBox(height: 30),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      // children: [circleMsg(message)]
                                      ),
                                  SizedBox(height: 20),
                                  recDetail(message.split("|")[0]),
                                  SizedBox(height: 20)
                                ]));
                          });
                    },
                    child: Column(children: [
                      if (message.split("|")[1] != "")
                        Row(children: [
                          Expanded(
                              child: Text(message.split("|")[1],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)))
                        ]),
                      if (message.split(":")[1] != "") SizedBox(height: 5),
                      // circleMsg(message.split("|")[0]),
                      SizedBox(height: 5),
                    ]))
                : Text(message,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, color: Colors.white))),
        showNip: true),
  );
}
