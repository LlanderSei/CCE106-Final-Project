import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: ListView(
        children: [
          TimelineTile(
            isFirst: true,
            indicatorStyle: const IndicatorStyle(color: Colors.green),
            endChild: const Padding(
                padding: EdgeInsets.all(8), child: Text('Order confirmation')),
          ),
          TimelineTile(
            indicatorStyle: const IndicatorStyle(color: Colors.green),
            endChild: const Padding(
                padding: EdgeInsets.all(8), child: Text('Order received')),
          ),
          TimelineTile(
            indicatorStyle: const IndicatorStyle(color: Colors.orange),
            endChild: const Padding(
                padding: EdgeInsets.all(8), child: Text('Food is ready')),
          ),
          TimelineTile(
            isLast: true,
            indicatorStyle: const IndicatorStyle(color: Colors.grey),
            endChild: const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Delivered - Enjoy the meal!')),
          ),
        ],
      ),
    );
  }
}
