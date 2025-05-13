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
  const PlaceListItem({super.key, required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          place.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '거리: ${place.distance.toStringAsFixed(0)}m',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: const Size(70, 30),
          ),
          child: const Text('길찾기', style: TextStyle(fontSize: 13)),
        ),
        onTap: onTap,
      ),
    );
  }
}
