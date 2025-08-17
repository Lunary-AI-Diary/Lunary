// 공통 하단 버튼

import 'package:flutter/material.dart';

Widget buildBottomButtons(
  BuildContext context, {
  required bool isEnabled,
  required Future<void> Function()? onContinue,
  String buttonText = "계속",
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Row(children: [Icon(Icons.arrow_back), Text(" 이전")]),
      ),
      ElevatedButton(
        onPressed: isEnabled && onContinue != null
            ? () async => await onContinue()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.orange : Colors.orange.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(buttonText),
      ),
    ],
  );
}
