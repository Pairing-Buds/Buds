// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../map_screen.dart';

/// 장소 목록 아이템 위젯
class PlaceListItem extends StatelessWidget {
  /// 장소 정보
  final Place place;
  
  /// 탭 이벤트 콜백
  final VoidCallback onTap;

  /// 생성자
  const PlaceListItem({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text(
          place.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('거리: ${place.distance.toStringAsFixed(0)}m'),
        trailing: ElevatedButton(
          onPressed: onTap,
          child: const Text('길찾기'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
} 