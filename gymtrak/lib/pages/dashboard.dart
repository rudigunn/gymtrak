import 'package:flutter/material.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Theme(
          data: ThemeData(splashFactory: NoSplash.splashFactory),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notification_important_outlined),
            splashColor: Colors.transparent,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 45),
                  splashFactory: NoSplash.splashFactory),
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add new chart'),
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: CardWidget(),
          );
        },
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  const CardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      surfaceTintColor: Colors.white,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('Card Title'),
                subtitle: Text('Subtitle'),
              ),
              Container(
                height: 200,
                child: Placeholder(), // Replace with your chart or image
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Some text at the bottom'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Handle settings button tap
              },
            ),
          ),
        ],
      ),
    );
  }
}
