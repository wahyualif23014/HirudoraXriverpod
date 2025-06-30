import 'package:flutter/material.dart';

class ActivityDetailPage extends StatelessWidget {
  final String activityId;
  const ActivityDetailPage({super.key, required this.activityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activity Detail - $activityId')),
      body: Center(child: Text('Details for Activity ID: $activityId')),
    );
  }
}