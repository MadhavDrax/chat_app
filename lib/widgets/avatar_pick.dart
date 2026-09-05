import 'package:flutter/material.dart';

class AvatarPick extends StatelessWidget {
  const AvatarPick({super.key});
  @override
  Widget build(BuildContext context) {
    final List<String> avatarList = [
      'assets/images/cat.png',
          'assets/images/bear.png',
          'assets/images/boy.png',
          'assets/images/avatar.png',
          'assets/images/human.png',
          'assets/images/profile.png',
          'assets/images/woman.png',
    ];
    return AlertDialog(
      title: Text(
        'Choose Avatar!',
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      ),

      content: SizedBox(
        height: 300,
        width: 300,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
              mainAxisSpacing: 12,
          ),
          itemCount: avatarList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context, avatarList[index]);
              },
              child: _avatarCircle(avatarList[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _avatarCircle(String imgUrl) {
    return CircleAvatar(radius: 40, backgroundImage: AssetImage(imgUrl));
  }
}
