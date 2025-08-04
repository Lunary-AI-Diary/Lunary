import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lunary/screens/chat/chat_screen.dart';
import 'package:lunary/screens/diary/diary_screen.dart';

class CalendarDialog extends StatefulWidget {
  final Function(String)? onDateSelected;

  const CalendarDialog({super.key, this.onDateSelected});

  @override
  State<CalendarDialog> createState() => _CalendarDialogState();
}

// 달력 위젯
class _CalendarDialogState extends State<CalendarDialog> {
  late DateTime selectedMonth;
  String? _selectedDateId; // 선택된 날짜 상태 추가

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
  }

  void _goToPreviousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
      _selectedDateId = null; // 월이 바뀌면 선택 해제
    });
  }

  void _goToNextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
      _selectedDateId = null; // 월이 바뀌면 선택 해제
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final startOffset = firstDay.weekday % 7;

    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.95),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: Colors.pink),
                  const SizedBox(width: 8),
                  const Text(
                    '기록',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.8),

            // 날짜 선택 바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _goToPreviousMonth,
                    child: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    '${selectedMonth.year}년 ${selectedMonth.month}월',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToNextMonth,
                    child: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),

            // 요일 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: ['일', '월', '화', '수', '목', '금', '토'].map((label) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // 날짜들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: startOffset + lastDay.day,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  if (index < startOffset) return const SizedBox.shrink();

                  final day = index - startOffset + 1;
                  final date = DateTime(
                    selectedMonth.year,
                    selectedMonth.month,
                    day,
                  );
                  final dateId = DateFormat('yyyy-MM-dd').format(date);

                  final isSelected = _selectedDateId == dateId;
                  final isToday =
                      dateId == DateFormat('yyyy-MM-dd').format(DateTime.now());
                  final isFuture = date.isAfter(DateTime.now());

                  return GestureDetector(
                    onTap: isFuture
                        ? null // 미래 날짜는 선택 불가
                        : () {
                            setState(() {
                              _selectedDateId = dateId;
                            });
                            widget.onDateSelected?.call(dateId);
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFE1B5)
                            : isToday
                            ? const Color(0xFFD6ECFF) // 오늘 날짜는 연한 파란색
                            : isFuture
                            ? Colors
                                  .grey
                                  .shade200 // 미래 날짜는 연한 회색
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.pink
                              : isToday
                              ? const Color(0xFF3399FF) // 오늘 날짜는 파란색 글씨
                              : isFuture
                              ? Colors
                                    .grey // 미래 날짜는 회색 글씨
                              : const Color(0xFF444444),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 날짜를 선택했을 때만 버튼 표시
            if (_selectedDateId != null) ...[
              const SizedBox(height: 16),
              Text(
                '선택된 날짜: $_selectedDateId',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8CBA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(dateId: _selectedDateId!),
                        ),
                      );
                    },
                    child: const Text('대화 기록'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDAC9C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiaryScreen(dateId: _selectedDateId!),
                        ),
                      );
                    },
                    child: const Text('일기 보기'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
