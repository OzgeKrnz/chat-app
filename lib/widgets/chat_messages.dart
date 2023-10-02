import 'package:chat_app/widgets/message_bubble.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    //messagebubble kullanıcı giriş yapan kullanıcı mı kontrol icin-- kullanıcı kimligi dogrulamak cin
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy(
            "createdAt",
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(), // mesajların gelmesini beklerken görüntülenecek ekran
          );
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text("Mesaj bulunamadı."),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(
            child: Text("Birşeyler ters gitti..."),
          );
        }

        final loadedMessages = chatSnapshots.data!.docs;

        return ListView.builder(
          //28.08
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
           
          ),
          reverse: true,

          //28.08
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            //28.08
            final ChatMessage = loadedMessages[index].data();

            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null; 

            final currentMessageUserId = ChatMessage["userId"];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage["userId"] : null;

            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                  message: ChatMessage["textMessage"],
                  isMe: authenticatedUser.uid == currentMessageUserId);
            }
            else {
              return MessageBubble.first(
                  username: ChatMessage["username"],
                  userImage: ChatMessage["userImage"],
                  message: ChatMessage["textMessage"],
                  isMe: authenticatedUser.uid == currentMessageUserId);
            }
          },
        );
      },
    );
  }
}
