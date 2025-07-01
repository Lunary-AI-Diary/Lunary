import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarDialog extends StatelessWidget {
  final Function(DateTime) onDateSelected;

  const CalendarDialog({super.key, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    // 오늘 날짜 기준 월로 시작
    DateTime selectedMonth = DateTime.now();
    DateTime firstDayOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      1,
    );
    DateTime lastDayOfMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4), // 회색 배경 처리
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFFFEEFEF), Color(0xFFFFF6F6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 다이얼로그 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.book, color: Colors.pink),
                  Text(
                    DateFormat('yyyy년 MM월').format(selectedMonth),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 요일 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final weekday = ['일', '월', '화', '수', '목', '금', '토'];
                  return Expanded(
                    child: Center(
                      child: Text(
                        weekday[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),

              // 날짜 표시
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: firstDayOfMonth.weekday - 1 + lastDayOfMonth.day,
                itemBuilder: (context, index) {
                  if (index < firstDayOfMonth.weekday - 1) {
                    return const SizedBox.shrink(); // 빈 칸
                  }

                  final day = index - (firstDayOfMonth.weekday - 2);
                  final date = DateTime(
                    selectedMonth.year,
                    selectedMonth.month,
                    day,
                  );

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // 다이얼로그 닫고
                      onDateSelected(date); // 선택된 날짜 전달
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
