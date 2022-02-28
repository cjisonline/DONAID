import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget recDetail(message) {
  List<String> list = [];
  if (message != null && message != "") {
    list = message.split(",");
  }

  return SingleChildScrollView(
    child: Column(
        children: list
            .map((e) => Container(
                margin: EdgeInsets.only(bottom: 5),
                width: Get.width / 1.1,
                decoration: BoxDecoration(
                    border: Border.all(),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Colors.grey, Colors.white],
                        tileMode: TileMode.repeated)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(e.split(":")[0].trim().capitalizeFirst??"",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('\n ' + e.split(":")[1].trim().capitalizeFirst.toString(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                            SizedBox(height: 8),
                            Column(children: [
                              Text(
                                  "• " + e.split(":")[2].trim().capitalizeFirst.toString(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ))
                            ]),
                            SizedBox(height: 8),
                          ])
                    ])))
            .toList()),
  );
}
