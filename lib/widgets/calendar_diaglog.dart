import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarDialog extends StatefulWidget {
  final Function(String) onDateSelected;

  const CalendarDialog({super.key, required this.onDateSelected});

  @override
  State<CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<CalendarDialog> {
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now(); // 처음엔 현재 월로 시작
  }

  // 월 선택 다이얼로그
  Future<void> _selectMonth() async {
    final picked = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('월 선택'),
        children: List.generate(12, (i) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, i + 1),
            child: Text('${i + 1}월'),
          );
        }),
      ),
    );
    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(selectedMonth.year, picked, 1);
      });
    }
  }

  // 연도 선택 다이얼로그
  Future<void> _selectYear() async {
    final currentYear = DateTime.now().year;
    final picked = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('연도 선택'),
        children: List.generate(21, (i) {
          final year = currentYear - 10 + i;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, year),
            child: Text('$year년'),
          );
        }),
      ),
    );
    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked, selectedMonth.month, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

    // 달력에서 첫 번째 날짜가 차지해야 할 인덱스(빈 칸 개수)
    final int startOffset = (firstDayOfMonth.weekday % 7);
    // 예: 월요일(1)이면 1, 일요일(7)이면 0

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
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
              // 헤더: 월/연도 선택 버튼 추가
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.book, color: Colors.pink),
                  Row(
                    children: [
                      // 연도 선택 버튼
                      GestureDetector(
                        onTap: _selectYear,
                        child: Row(
                          children: [
                            Text(
                              '${selectedMonth.year}년',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 20),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 월 선택 버튼
                      GestureDetector(
                        onTap: _selectMonth,
                        child: Row(
                          children: [
                            Text(
                              '${selectedMonth.month}월',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 요일
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  const weekday = [
                    'Sun',
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                  ];
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

              // 날짜들
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: startOffset + lastDayOfMonth.day,
                itemBuilder: (context, index) {
                  if (index < startOffset) {
                    return const SizedBox.shrink();
                  }

                  final day = index - startOffset + 1;
                  final date = DateTime(
                    selectedMonth.year,
                    selectedMonth.month,
                    day,
                  );
                  final dateId = DateFormat('yyyy-MM-dd').format(date);

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onDateSelected(dateId); // 문자열로 전달
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
