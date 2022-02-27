// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:circle_list/circle_list.dart';
// import 'package:donaid/Controller/chatController.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// Widget optionals(ChatController chatController, BuildContext context) {
//   return Container(
//       height: 350,
//       color: Colors.grey.shade700,
//       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//         CircleList(
//             innerRadius: 110,
//             outerRadius: 175,
//             initialAngle: .3,
//             centerWidget: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height: 12),
//                 Container(
//                   height: 23,
//                   width: Get.width / 4,
//                   decoration: BoxDecoration(
//                       color: Colors.grey.shade700,
//                       borderRadius: BorderRadius.circular(30)),
//                   child: Center(
//                     child: AutoSizeText(
//                       chatController.l1.name,
//                       maxLines: 1,
//                       maxFontSize: 12,
//                       textAlign: TextAlign.center,
//                       minFontSize: 5,
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 6),
//                 Container(
//                     height: 150,
//                     width: Get.width / 2.8,
//                     child: Center(
//                         child: Container(
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(30),
//                               topRight: Radius.circular(30),
//                               bottomLeft: Radius.circular(30),
//                               bottomRight: Radius.circular(30)),
//                           border: Border.all(color: Colors.blue)),
//                       child: ListWheelScrollView(
//                         itemExtent: 30,
//                         diameterRatio: 4,
//                         useMagnifier: true,
//                         magnification: 1.5,
//                         onSelectedItemChanged: (pr) {
//                           Levels level = MyGlobals.levels
//                               .where((e) => e.p == chatController.l1.id)
//                               .toList()[pr];
//                           chatController.l2 = level;
//                           chatController.update();
//                         },
//                         children: MyGlobals.levels
//                             .where((e) => e.p == chatController.l1.id)
//                             .toList()
//                             .map((e) => Container(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: .0, horizontal: .0),
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                         child: Padding(
//                                             padding: EdgeInsets.all(5.0),
//                                             child: AutoSizeText(
//                                               e.name.capitalizeFirst,
//                                               maxLines: 1,
//                                               maxFontSize: 12,
//                                               textAlign: TextAlign.center,
//                                               minFontSize: 5,
//                                               style:
//                                                   TextStyle(color: Colors.grey),
//                                             ))),
//                                     Divider(
//                                         color: Colors.transparent, height: 0),
//                                   ],
//                                 )))
//                             .toList(),
//                       ),
//                     ))),
//                 SizedBox(height: 15),
//               ],
//             ),
//             innerCircleRotateWithChildren: false,
//             showInitialAnimation: false,
//             rotateMode: RotateMode.onlyChildrenRotate,
//             innerCircleColor: Colors.grey.shade900,
//             outerCircleColor: Colors.black,
//             origin: Offset(0, 0),
//             children: MyGlobals.levels
//                 .where((e) => e.p == null)
//                 .map((e) => InkWell(
//                       onTap: () {
//                         chatController.l1 = e;
//                         chatController.l2 = Levels();
//                         chatController.update();
//                       },
//                       child: Container(
//                           child: Center(
//                             child: Padding(
//                                 padding: EdgeInsets.all(5.0),
//                                 child: AutoSizeText(
//                                   e.name.capitalizeFirst,
//                                   maxLines: 2,
//                                   maxFontSize: 9.0,
//                                   textAlign: TextAlign.center,
//                                   minFontSize: 4,
//                                   style: TextStyle(color: Colors.white),
//                                 )),
//                           ),
//                           height: 60,
//                           width: 60,
//                           decoration: BoxDecoration(
//                               color: Colors.blueGrey.shade900,
//                               shape: BoxShape.circle)),
//                     ))
//                 .toList())
//       ]));
// }

// Widget list(ChatController chatController) {
//   return Expanded(
//       child: Container(
//           color: Colors.grey.shade700,
//           height: 420,
//           child: ListView(
//               children: MyGlobals.levels
//                   .where((e) => e.p == chatController.l2.id)
//                   .toList()
//                   .map((e) => Column(children: [
//                         InkWell(
//                             onTap: () {
//                               String value =
//                                   "${chatController.l1.name}:${chatController.l2.name}:${e.name}";
//                               if (chatController.ids.contains(e.id)) {
//                                 chatController.ids.remove(e.id);
//                                 chatController.list.remove(value);
//                               } else {
//                                 chatController.ids.add(e.id);
//                                 chatController.list.add(value);
//                               }
//                               chatController.update();
//                             },
//                             child: Padding(
//                                 padding: EdgeInsets.all(5.0),
//                                 child: AutoSizeText(
//                                   e.name.capitalizeFirst,
//                                   maxLines: 2,
//                                   maxFontSize: 12,
//                                   textAlign: TextAlign.center,
//                                   minFontSize: 5,
//                                   style: TextStyle(
//                                       color: chatController.ids.contains(e.id)
//                                           ? Colors.blue
//                                           : Colors.white),
//                                 ))),
//                         Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 100, vertical: 4),
//                             child: Container(color: Colors.blue, height: 1))
//                       ]))
//                   .toList())));
// }
