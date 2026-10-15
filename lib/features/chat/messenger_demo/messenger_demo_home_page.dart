import 'package:dashboard/features/chat/messenger_demo/messenger_chat_model.dart';
import 'package:dashboard/features/chat/messenger_demo/messenger_story_model.dart';
import 'package:dashboard/features/chat/messenger_demo/messenger_remote_image.dart';
import 'package:flutter/material.dart';

class MessengerDemoHomePage extends StatelessWidget {
  const MessengerDemoHomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey.shade200,
    appBar: AppBar(title: const Text('Home')),
    body: Column(
      children: [
        SizedBox(
          height: 208,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: storiesMockData.length,
            itemBuilder: (context, index) {
              final story = storiesMockData[index];
              return SizedBox(
                width: 110,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: MessengerRemoteImage(
                              url: story.storyImageUrl,
                              width: 100,
                              height: 140,
                            ),
                          ),
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: story.storySeen
                                ? Colors.grey
                                : const Color(0xFF2845E7),
                            child: CircleAvatar(
                              radius: 23,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: MessengerRemoteImage(
                                  url: story.profileImageUrl,
                                  width: 44,
                                  height: 44,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        story.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${story.day} ${story.time}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: chatMockData.length,
            itemBuilder: (context, index) {
              final chat = chatMockData[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: ClipOval(
                      child: MessengerRemoteImage(
                        url: chat.imageUrl,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  title: Text(chat.name, maxLines: 1),
                  subtitle: Text(chat.message, maxLines: 1),
                  trailing: Text(chat.time),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
