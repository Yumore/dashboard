import 'package:dashboard/features/chat/messenger_demo/messenger_call_model.dart';
import 'package:dashboard/features/chat/messenger_demo/messenger_remote_image.dart';
import 'package:flutter/material.dart';

class MessengerDemoCallsPage extends StatelessWidget {
  const MessengerDemoCallsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey.shade200,
    appBar: AppBar(title: const Text('Calls')),
    body: ListView.builder(
      itemCount: callMockData.length,
      itemBuilder: (context, index) {
        final call = callMockData[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: ClipOval(
                child: MessengerRemoteImage(
                  url: call.profileImageUrl,
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            title: Text(call.name),
            subtitle: Text('${call.day} | ${call.time} · ${call.callType}'),
            trailing: Icon(
              call.callSource == 'video' ? Icons.videocam : Icons.call,
              color: const Color(0xFF2845E7),
            ),
          ),
        );
      },
    ),
  );
}
