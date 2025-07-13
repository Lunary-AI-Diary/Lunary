import 'package:flutter/material.dart';

// 일기 화면 플로팅 액션 버튼 위젯
// TODO: 현재는 일기 재생성만 구현되어 있음. 리뷰 재생성 기능 구현할 것.
// TODO: 일기 로딩, 리뷰 로딩 분리 필요. onRegenerateDiary와 같이 onRegenerateReview 추가 필요.
class DiaryFloatingActionButton extends StatelessWidget {
  final int tabIndex;
  final bool isLoading;
  final VoidCallback onRegenerateDiary;

  const DiaryFloatingActionButton({
    super.key,
    required this.tabIndex,
    required this.isLoading,
    required this.onRegenerateDiary,
  });

  @override
  Widget build(BuildContext context) {
    if (tabIndex == 0) {
      // AI 일기 탭
      return FloatingActionButton.extended(
        onPressed: isLoading ? null : onRegenerateDiary,
        icon: const Icon(Icons.refresh),
        label: const Text("일기 재생성"),
      );
    } else if (tabIndex == 1) {
      // AI 리뷰 탭
      return FloatingActionButton.extended(
        onPressed: () {
          // TODO: 리뷰 재생성 기능 구현할 것
        },
        icon: const Icon(Icons.refresh),
        label: const Text("리뷰 재생성"),
      );
    } else {
      // 리포트 탭
      return const SizedBox.shrink();
    }
  }
}
