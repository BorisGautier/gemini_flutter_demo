import 'package:flutter/material.dart';
import 'package:kartia/src/core/utils/colors.util.dart';

enum SnackbarType { error, success, info, custom }

class KartiaSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    String? title,
    Color? customColor,
    IconData? customIcon,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case SnackbarType.error:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case SnackbarType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case SnackbarType.info:
        backgroundColor = AppColors.primary;
        icon = Icons.info;
        break;
      case SnackbarType.custom:
        backgroundColor = customColor ?? AppColors.secondary;
        icon = customIcon ?? Icons.notifications;
        break;
    }

    final snackBar = SnackBar(
      duration: duration,
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
