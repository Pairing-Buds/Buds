import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/step_info_widget.dart';
import 'widgets/step_action_buttons.dart';
import 'package:buds/providers/my_page_provider.dart';

class StepDetailScreen extends StatelessWidget {
  const StepDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myPageProvider = Provider.of<MyPageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('만보기'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          StepInfoWidget(
            goalSteps: myPageProvider.targetSteps,
            currentSteps: myPageProvider.currentSteps,
          ),
          const StepActionButtons(),
        ],
      ),
    );
  }
}
