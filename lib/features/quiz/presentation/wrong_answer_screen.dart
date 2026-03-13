import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

/// Placeholder for the wrong answer explanation screen.
class WrongAnswerScreen extends StatelessWidget {
  const WrongAnswerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text('Wrong Answer', style: AppTextStyles.h1),
      ),
    );
  }
}
