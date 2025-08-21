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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          elevation: isEnabled ? 1 : 0, // 입체감
          shadowColor: isEnabled ? Colors.black : Colors.transparent, // 그림자 색상
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: isEnabled ? null : const Color(0xFFCCCCCC), // 비활성화 시 단색 회색
            gradient: isEnabled
                ? const LinearGradient(
                    colors: [Color(0xFFFF5D8C), Color(0xFFFFC56B)],
                  )
                : null, // 활성화 시에만 그라디언트
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(minWidth: 100, minHeight: 48),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
