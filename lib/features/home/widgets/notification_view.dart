// lib/view/home/notification_view.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List notificationArr = [
    {
      "image": "assets/img/Workout1.png",
      "title": "Hey, it's time for lunch",
      "time": "About 1 minutes ago",
    },
    {
      "image": "assets/img/Workout2.png",
      "title": "Don't miss your lowerbody workout",
      "time": "About 3 hours ago",
    },
    {
      "image": "assets/img/Workout3.png",
      "title": "Hey, let's add some meals for your breakfast",
      "time": "About 3 hours ago",
    },
    {
      "image": "assets/img/Workout1.png",
      "title": "Congratulations, You have finished Ab workout!",
      "time": "29 May",
    },
    {
      "image": "assets/img/Workout2.png",
      "title": "Hey, it's time for lunch",
      "time": "8 April",
    },
    {
      "image": "assets/img/Workout3.png",
      "title": "Ups, You have missed your Lowerbody workout",
      "time": "8 April",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Notification",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              // Show more options
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        itemBuilder: ((context, index) {
          var nObj = notificationArr[index] as Map? ?? {};
          return NotificationRow(nObj: nObj);
        }),
        separatorBuilder: (context, index) {
          return Divider(color: AppColors.gray.withOpacity(0.5), height: 1);
        },
        itemCount: notificationArr.length,
      ),
    );
  }
}

class NotificationRow extends StatelessWidget {
  final Map nObj;
  const NotificationRow({super.key, required this.nObj});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              nObj["image"].toString(),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nObj["title"].toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nObj["time"].toString(),
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
