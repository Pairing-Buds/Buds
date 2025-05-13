// Dart imports:
import 'dart:math';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

// Project imports:
import 'package:buds/screens/map/map_screen.dart';
import 'package:buds/services/location_service.dart';
import 'package:buds/constants/api_constants.dart';

class StepActionButtons extends StatefulWidget {
  const StepActionButtons({super.key});

  @override
  State<StepActionButtons> createState() => _StepActionButtonsState();
}

class _StepActionButtonsState extends State<StepActionButtons> {
  // 위치 서비스
  final LocationService _locationService = LocationService();
  // 도서관 목록 표시 여부
  bool _isLibraryListVisible = false;
  // 공원 목록 표시 여부
  bool _isParkListVisible = false;
  // 로딩 상태
  bool _isLoading = false;
  // 위치 로딩 중 여부
  bool _isLocationLoading = false;
  // 현재 위치
  LatLng? _currentLocation;
  // 주변 도서관 목록
  List<Library> _nearbyLibraries = [];
  // 주변 공원 목록
  List<Park> _nearbyParks = [];

  // 지도 화면으로 이동 (장소 타입 지정)
  void _navigateToMapScreen({String placeType = 'park', PlaceInfo? place}) {
    Map<String, dynamic> args = {'placeType': placeType};

    // 특정 장소 정보가 있으면 추가
    if (place != null) {
      args['targetLibrary'] = {
        'id': place.id,
        'name': place.name,
        'lat': place.location.latitude,
        'lng': place.location.longitude,
      };
    } else {
      // 목록 자동 표시 플래그 추가
      args['showList'] = true;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
        settings: RouteSettings(arguments: args),
      ),
    );
  }

  // 현재 위치 가져오기
  Future<bool> _fetchCurrentLocation() async {
    if (_currentLocation != null) return true;

    setState(() {
      _isLocationLoading = true;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        setState(() {
          _isLocationLoading = false;
        });
        _showErrorSnackBar('위치 정보를 가져올 수 없습니다.');
        return false;
      }

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLocationLoading = false;
      });

      return true;
    } catch (e) {
      setState(() {
        _isLocationLoading = false;
      });
      _showErrorSnackBar('위치 정보를 가져오는 중 오류가 발생했습니다.');
      debugPrint('위치 가져오기 오류: $e');
      return false;
    }
  }

  // 주변 도서관 가져오기
  Future<void> _fetchNearbyLibraries() async {
    if (_nearbyLibraries.isNotEmpty) return;

    bool hasLocation = await _fetchCurrentLocation();
    if (!hasLocation) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 실제 Places API를 호출하여 주변 도서관 찾기
      final libraries = await _searchNearbyPlaces('library');

      setState(() {
        _nearbyLibraries =
            libraries
                .map(
                  (place) => Library(
                    id: place['place_id'] as String,
                    name: place['name'] as String,
                    address: place['vicinity'] as String? ?? '주소 정보 없음',
                    distance: _calculateDistance(
                      _currentLocation!.latitude,
                      _currentLocation!.longitude,
                      place['geometry']['location']['lat'] as double,
                      place['geometry']['location']['lng'] as double,
                    ),
                    location: LatLng(
                      place['geometry']['location']['lat'] as double,
                      place['geometry']['location']['lng'] as double,
                    ),
                  ),
                )
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('주변 도서관을 검색하는 중 오류가 발생했습니다.');
      debugPrint('도서관 검색 오류: $e');

      // 오류 발생 시 예비 더미 데이터 사용
      _nearbyLibraries = _getMockLibraries();
    }
  }

  // 주변 공원 가져오기
  Future<void> _fetchNearbyParks() async {
    if (_nearbyParks.isNotEmpty) return;

    bool hasLocation = await _fetchCurrentLocation();
    if (!hasLocation) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 실제 Places API를 호출하여 주변 공원 찾기
      final parks = await _searchNearbyPlaces('park');

      setState(() {
        _nearbyParks =
            parks
                .map(
                  (place) => Park(
                    id: place['place_id'] as String,
                    name: place['name'] as String,
                    address: place['vicinity'] as String? ?? '주소 정보 없음',
                    description:
                        place['types']?.isNotEmpty == true
                            ? '공원 유형: ${(place['types'] as List).join(', ')}'
                            : '공원 설명 정보가 없습니다.',
                    distance: _calculateDistance(
                      _currentLocation!.latitude,
                      _currentLocation!.longitude,
                      place['geometry']['location']['lat'] as double,
                      place['geometry']['location']['lng'] as double,
                    ),
                    location: LatLng(
                      place['geometry']['location']['lat'] as double,
                      place['geometry']['location']['lng'] as double,
                    ),
                  ),
                )
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('주변 공원을 검색하는 중 오류가 발생했습니다.');
      debugPrint('공원 검색 오류: $e');

      // 오류 발생 시 예비 더미 데이터 사용
      _nearbyParks = _getMockParks();
    }
  }

  // Google Places API를 호출하여 주변 장소 검색
  Future<List<Map<String, dynamic>>> _searchNearbyPlaces(String type) async {
    if (_currentLocation == null) return [];

    try {
      final apiKey = ApiConstants.googleMapsApiKey;
      if (apiKey.isEmpty) {
        throw Exception('Google Maps API 키가 설정되지 않았습니다.');
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${_currentLocation!.latitude},${_currentLocation!.longitude}'
        '&radius=1500'
        '&type=$type'
        '&key=$apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Places API 응답: ${data['status']}');

        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['results']);
        }
        throw Exception('API 응답 오류: ${data['status']}');
      }
      throw Exception('네트워크 오류: ${response.statusCode}');
    } catch (e) {
      debugPrint('Places API 호출 오류: $e');
      throw e;
    }
  }

  // 두 좌표 사이의 거리 계산 (미터 단위)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000; // 지구 반지름 (미터)
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // 미터 단위 거리
  }

  // 각도를 라디안으로 변환
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // 테스트용 도서관 데이터 (API 호출 실패시 백업용)
  List<Library> _getMockLibraries() {
    if (_currentLocation == null) return [];

    final rnd = Random();

    return [
      Library(
        id: '1',
        name: '중앙 도서관',
        address: '서울특별시 강남구 테헤란로 123',
        distance: 350 + rnd.nextInt(150).toDouble(),
        location: LatLng(
          _currentLocation!.latitude + 0.001,
          _currentLocation!.longitude + 0.002,
        ),
      ),
      Library(
        id: '2',
        name: '디지털 도서관',
        address: '서울특별시 강남구 선릉로 456',
        distance: 520 + rnd.nextInt(200).toDouble(),
        location: LatLng(
          _currentLocation!.latitude - 0.001,
          _currentLocation!.longitude - 0.001,
        ),
      ),
      Library(
        id: '3',
        name: '구립 문화 도서관',
        address: '서울특별시 강남구 삼성로 789',
        distance: 780 + rnd.nextInt(300).toDouble(),
        location: LatLng(
          _currentLocation!.latitude + 0.002,
          _currentLocation!.longitude - 0.002,
        ),
      ),
    ];
  }

  // 테스트용 공원 데이터 (API 호출 실패시 백업용)
  List<Park> _getMockParks() {
    if (_currentLocation == null) return [];

    final rnd = Random();

    return [
      Park(
        id: '1',
        name: '작은 공원',
        address: '서울특별시 강남구 역삼동 123',
        description: '조용한 동네 공원입니다. 산책로와 벤치가 있습니다.',
        distance: 250 + rnd.nextInt(150).toDouble(),
        location: LatLng(
          _currentLocation!.latitude + 0.001,
          _currentLocation!.longitude + 0.001,
        ),
      ),
      Park(
        id: '2',
        name: '수완 백조 공원',
        address: '서울특별시 강남구 대치동 456',
        description: '대형 호수와 잔디밭이 있는 공원입니다. 백조 모양의 보트를 타실 수 있습니다.',
        distance: 150 + rnd.nextInt(200).toDouble(),
        location: LatLng(
          _currentLocation!.latitude - 0.001,
          _currentLocation!.longitude - 0.001,
        ),
      ),
      Park(
        id: '3',
        name: '장수마을 공원',
        address: '서울특별시 강남구 삼성동 789',
        description: '운동 시설과 산책로가 잘 갖춰진 공원입니다.',
        distance: 300 + rnd.nextInt(250).toDouble(),
        location: LatLng(
          _currentLocation!.latitude + 0.002,
          _currentLocation!.longitude - 0.002,
        ),
      ),
    ];
  }

  // 에러 메시지 표시
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // 도서관 목록 토글
  void _toggleLibraryList() async {
    // 위치 로딩 중이면 무시
    if (_isLocationLoading) return;

    // 공원 목록이 보이고 있으면 닫기
    if (_isParkListVisible) {
      setState(() {
        _isParkListVisible = false;
      });
    }

    setState(() {
      _isLibraryListVisible = !_isLibraryListVisible;
    });

    if (_isLibraryListVisible && _nearbyLibraries.isEmpty) {
      await _fetchNearbyLibraries();
    }
  }

  // 공원 목록 토글
  void _toggleParkList() async {
    // 위치 로딩 중이면 무시
    if (_isLocationLoading) return;

    // 도서관 목록이 보이고 있으면 닫기
    if (_isLibraryListVisible) {
      setState(() {
        _isLibraryListVisible = false;
      });
    }

    setState(() {
      _isParkListVisible = !_isParkListVisible;
    });

    if (_isParkListVisible && _nearbyParks.isEmpty) {
      await _fetchNearbyParks();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 거리순으로 정렬된 상위 3개 장소 목록
    List<Library> topLibraries = [];
    List<Park> topParks = [];

    if (_nearbyLibraries.isNotEmpty) {
      // 거리순으로 정렬
      final sortedLibraries = List<Library>.from(_nearbyLibraries)
        ..sort((a, b) => a.distance.compareTo(b.distance));
      // 상위 3개만 선택
      topLibraries = sortedLibraries.take(3).toList();
    }

    if (_nearbyParks.isNotEmpty) {
      // 거리순으로 정렬
      final sortedParks = List<Park>.from(_nearbyParks)
        ..sort((a, b) => a.distance.compareTo(b.distance));
      // 상위 3개만 선택
      topParks = sortedParks.take(3).toList();
    }

    return Column(
      children: [
        // 기본 버튼들
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // 도서관 버튼 및 목록
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // 도서관 버튼
                    ListTile(
                      leading: const Icon(
                        Icons.menu_book,
                        size: 32,
                        color: Colors.green,
                      ),
                      title: const Text('도서관 목록 보기'),
                      trailing: Icon(
                        _isLibraryListVisible
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      onTap: _toggleLibraryList,
                    ),

                    // 도서관 목록 (토글 방식)
                    if (_isLibraryListVisible)
                      _isLoading
                          ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : topLibraries.isEmpty
                          ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('주변 도서관을 찾을 수 없습니다.'),
                          )
                          : Column(
                            children:
                                topLibraries
                                    .map(
                                      (library) =>
                                          _buildCompactLibraryItem(library),
                                    )
                                    .toList(),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 공원 버튼 및 목록
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // 공원 버튼
                    ListTile(
                      leading: const Icon(
                        Icons.park,
                        size: 32,
                        color: Colors.green,
                      ),
                      title: const Text('공원 목록 보기'),
                      trailing: Icon(
                        _isParkListVisible
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      onTap: _toggleParkList,
                    ),

                    // 공원 목록 (토글 방식)
                    if (_isParkListVisible)
                      _isLoading
                          ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : topParks.isEmpty
                          ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('주변 공원을 찾을 수 없습니다.'),
                          )
                          : Column(
                            children:
                                topParks
                                    .map((park) => _buildCompactParkItem(park))
                                    .toList(),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 위치 로딩 인디케이터
        if (_isLocationLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('위치 정보를 가져오는 중...'),
                ],
              ),
            ),
          ),

        // 더 많은 장소 보기 버튼들
        if (_isLibraryListVisible && topLibraries.isNotEmpty ||
            _isParkListVisible && topParks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_isLibraryListVisible) {
                    _navigateToMapScreen(placeType: 'library');
                  } else if (_isParkListVisible) {
                    _navigateToMapScreen(placeType: 'park');
                  }
                },
                icon: const Icon(Icons.map, size: 18),
                label: Text(
                  '지도에서 더 많은 ${_isLibraryListVisible ? "도서관" : "공원"} 보기',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

        const Spacer(),
      ],
    );
  }

  // 컴팩트한 도서관 항목 위젯 (토글 메뉴용)
  Widget _buildCompactLibraryItem(Library library) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 왼쪽 아이콘 및 정보
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.local_library, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        library.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${library.distance.toInt()}m',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 오른쪽 길찾기 버튼
          SizedBox(
            height: 30,
            child: ElevatedButton.icon(
              onPressed:
                  () => _navigateToMapScreen(
                    placeType: 'library',
                    place: library,
                  ),
              icon: const Icon(Icons.directions, size: 14),
              label: const Text('길찾기', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 컴팩트한 공원 항목 위젯 (토글 메뉴용)
  Widget _buildCompactParkItem(Park park) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 왼쪽 아이콘 및 정보
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.park, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        park.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${park.distance.toInt()}m',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 오른쪽 길찾기 버튼
          SizedBox(
            height: 30,
            child: ElevatedButton.icon(
              onPressed:
                  () => _navigateToMapScreen(placeType: 'park', place: park),
              icon: const Icon(Icons.directions, size: 14),
              label: const Text('길찾기', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 장소 정보 공통 인터페이스
abstract class PlaceInfo {
  String get id;
  String get name;
  LatLng get location;
}

// 도서관 정보 클래스
class Library implements PlaceInfo {
  @override
  final String id;
  @override
  final String name;
  final String address;
  final double distance;
  @override
  final LatLng location;

  Library({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.location,
  });
}

// 공원 정보 클래스
class Park implements PlaceInfo {
  @override
  final String id;
  @override
  final String name;
  final String address;
  final String description;
  final double distance;
  @override
  final LatLng location;

  Park({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.distance,
    required this.location,
  });
}
