import 'package:donaid/Models/message.dart';
import 'package:donaid/globals.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/state_manager.dart';

var chatListener;
class ChatService extends GetxService {
  DatabaseReference dbRefMessages =
      FirebaseDatabase.instance.ref().child('chat');

  /*
  In this we will get all the previous message which is send and received between currentUser and his friends.
  */
  Future<void> getFriendsData(myId) async {
    try {
      await dbRefMessages.child(myId).once().then((value) {
        if (value.snapshot.exists) {
          var data = value.snapshot.value;
          (data as Map).forEach((key2, myvalue2) async {
            myvalue2.forEach((key, myvalue) {
              try {
                MessageModel temp = MessageModel.toModel(key, myvalue);
                temp.receiverId = key2;
                MyGlobals.allMessages.add(temp);
              } catch (e) {
                print(e);
              }
            });
          });
          var temp = MyGlobals.allMessages.toList();
          MyGlobals.allMessages.clear();
          for (var item in temp) {
            if (MyGlobals.allMessages.where((p0) => p0.id == item.id).isEmpty) {
              MyGlobals.allMessages.add(item);
            }
          }
          MyGlobals.allMessages
              .sort((a, b) => a.creationDate.compareTo(b.creationDate));
          print(MyGlobals.allMessages);
        }
        return value;
      });
    } catch (e) {
      EasyLoading.showInfo(e.toString(), duration: Duration(seconds: 3));
    }
  }

  /*
  In this we make the listener on our message parent child, like when even any child is added in the parent we will know and
  we are able to display on our screen, it is user for the realtime chat implementation.
  */
  listenFriend(myId, type) {
    try {
      print(MyGlobals.allMessages);
      chatListener = dbRefMessages.child(myId).onChildChanged.listen((event) {
        if (event.snapshot.value != null) {
          (event.snapshot.value as Map).forEach((key, myvalue) async {
            try {
              MessageModel temp = MessageModel.toModel(key, myvalue);
              temp.receiverId = event.snapshot.key!;
              MyGlobals.allMessages.add(temp);
              print(MyGlobals.allMessages);
            } catch (e) {
              print(e);
            }
          });
          var temp = MyGlobals.allMessages.toList();
          MyGlobals.allMessages.clear();
          for (var item in temp) {
            if (MyGlobals.allMessages.where((p0) => p0.id == item.id).isEmpty) {
              MyGlobals.allMessages.add(item);
            }
          }
          MyGlobals.allMessages
              .sort((a, b) => a.creationDate.compareTo(b.creationDate));
          print(MyGlobals.allMessages);
        }
      });
    } catch (e) {
      EasyLoading.showInfo(e.toString(), duration: Duration(seconds: 3));
    }
  }
  /*
  send the message and also save it in the realtime database, the message is saved 2 time, one for the sender and one for the receiver
  */
  Future<void> sendMessage(MessageModel message) async {
    try {
      String? id = dbRefMessages.push().key;
      await dbRefMessages
          .child(message.senderId)
          .child(message.receiverId)
          .child(id!)
          .set(message.toSendMessageJSON());
      await dbRefMessages
          .child(message.receiverId)
          .child(message.senderId)
          .child(id)
          .set(message.toSendMessageJSON());
    } catch (e) {
      EasyLoading.showInfo(e.toString(), duration: Duration(seconds: 3));
    }
  }
}
