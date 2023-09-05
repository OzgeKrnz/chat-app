
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  @override
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  // when dealing with controller this must be added
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  //mesaj gönderildiginde veriyi firebasede tutan fonk
  void _submitMessage() async {

    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    // metin kutusundaki odagı saglamak icin kullanılır.
    FocusScope.of(context).unfocus();
    _messageController.clear(); //reset



    // to get userId info(current user)
    final user = FirebaseAuth.instance.currentUser!;

    //to get username and userImage from firestore
    //get --> firestorea http req atması iicn --
    // koleksiyonda depolanan verileri alır, kullanıcı verileri olarak döndürür.
    final userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    //send to Firebase add -> belgeyi dinamik olarak eklemej için
    FirebaseFirestore.instance.collection("chat").add({
      "textMessage": enteredMessage,
      "createdAt": Timestamp.now(),
      "userId": user.uid,
      "username": userData.data()!["username"],
      "userImage": userData.data()!["image_url"],
    });

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            // kullanıcı tarafından girilen degeri tutan controller
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: const InputDecoration(labelText: "Mesaj gönder..."),
          ),
        ),
        IconButton(
          color: Theme.of(context).colorScheme.primary,
          icon: const Icon(
            Icons.send,
          ),
          onPressed: _submitMessage,
        )
      ]),
    );
  }
}
