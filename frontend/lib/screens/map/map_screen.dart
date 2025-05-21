// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Project imports:
import 'package:buds/constants/api_constants.dart';
import 'package:buds/services/location_service.dart';
import 'package:buds/widgets/toast_bar.dart';
import 'widgets/place_list_item.dart';

// Google API 키는 환경 변수로 관리됩니다

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Google Maps 컨트롤러
  GoogleMapController? _controller;
  // 현재 위치
  Position? _currentPosition;
  // 마커 세트
  final Set<Marker> _markers = {};
  // 폴리라인 (경로)
  final Map<PolylineId, Polyline> _polylines = {};
  // 장소 표시 여부
  bool _isPlacesVisible = false;
  // 주변 장소 목록
  List<Place> _nearbyPlaces = [];
  // 위치 서비스
  final LocationService _locationService = LocationService();
  // 로딩 상태
  bool _isLoading = false;
  // 선택된 장소
  Place? _selectedPlace;
  // 현재 선택된 장소 유형
  String _currentPlaceType = 'park'; // 'park' 또는 'library'
  // 장소 타입 표시 텍스트
  Map<String, String> _placeTypeText = {'park': '주변 공원', 'library': '주변 도서관'};

  @override
  void initState() {
    super.initState();

    // 화면이 그려진 직후 arguments 처리를 먼저 하고 위치 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processArguments();
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorDialog('위치 서비스가 비활성화되었습니다. 설정에서 위치 서비스를 활성화해주세요.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog('위치 권한이 거부되었습니다.');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorDialog('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: '내 위치'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
        _isLoading = false;
      });

      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ),
      );

      // 테스트 - 맵 스타일 설정
      _setMapStyle();

      // 위치를 가져온 후 인자를 다시 확인하고, 필요하면 장소 검색 시작
      if (_isPlacesVisible) {
        _searchNearbyPlaces();
      }
    } catch (e) {
     
      _showErrorDialog('위치 정보를 가져오는 중 오류가 발생했습니다.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 지도 스타일 설정 (선택사항)
  Future<void> _setMapStyle() async {
    if (_controller == null) return;

    try {
      await _controller!.setMapStyle('''
        [
          {
            "featureType": "poi.park",
            "elementType": "geometry.fill",
            "stylers": [
              {
                "color": "#c8e6c9"
              }
            ]
          },
          {
            "featureType": "poi.park",
            "elementType": "labels.text",
            "stylers": [
              {
                "weight": 2
              }
            ]
          }
        ]
      ''');
     
    } catch (e) {
      
    }
  }

  // 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('오류'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  // 주변 장소 검색
  Future<void> _searchNearbyPlaces() async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
      // 현재 위치 마커만 남기고 모든 마커 제거
      _markers.removeWhere(
        (marker) => marker.markerId.value != 'currentLocation',
      );
      // 폴리라인 제거
      _polylines.clear();
    });

    try {
      // Places API를 사용하여 주변 장소 검색
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
          'location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
          '&radius=3000&type=$_currentPlaceType&strictbounds=true'
          '&keyword=${_currentPlaceType == 'library' ? '도서관|시립도서관|구립도서관|공공도서관|학교도서관' : '공원'}'
          '&language=ko&key=${ApiConstants.googleMapsApiKey}',
        ),
      );

      List<Place> places = [];

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
      

        if (data['status'] == 'OK') {
          places =
              (data['results'] as List)
                  .map((place) {
                    final lat = place['geometry']['location']['lat'];
                    final lng = place['geometry']['location']['lng'];
                    final distance = _calculateDistance(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                      lat,
                      lng,
                    );

                    // 장소 타입 확인
                    final types = place['types'] as List?;
                    final name = place['name'] as String;

                    // 회사 제외 로직 - 회사 필터링 조건 완화 (센터는 제외, 일부 조건만 체크)
                    final bool isCompany =
                        name.contains('(주)') ||
                        name.contains('주식회사') ||
                        name.contains('Inc') ||
                        name.contains('회사') ||
                        name.contains('기술') ||
                        name.contains('센터') ||
                        name.contains('산업') ||
                        name.contains('스터디');

                    // 도서관인지 확인하는 로직 수정 및 완화 - 괄호 수정 및 도서관 조건 완화
                    final bool isLibrary =
                        _currentPlaceType == 'library' &&
                        ((types != null && types.contains('library')) ||
                            name.contains('도서관') ||
                            name.contains('책방') ||
                            name.contains('북카페') ||
                            name.toLowerCase().contains('library'));

                    // 공원인지 확인
                    final bool isPark =
                        _currentPlaceType == 'park' &&
                        ((types != null && types.contains('park')) ||
                            name.contains('공원'));

                    // 올바른 타입이고 회사가 아닌 경우에만 목록에 추가
                    final bool isCorrectType =
                        (_currentPlaceType == 'library' ? isLibrary : isPark) &&
                        (_currentPlaceType == 'library'
                            ? !isCompany || name.contains('도서관')
                            : true);

                    // 디버그 출력 추가
                    if (_currentPlaceType == 'library') {
                     
                    }

                    // 올바른 타입인 경우에만 목록에 추가
                    if (isCorrectType) {
                      return Place(
                        id: place['place_id'],
                        name: place['name'],
                        location: LatLng(lat, lng),
                        distance: distance,
                      );
                    }
                    // 올바른 타입이 아니면 null 반환
                    return null;
                  })
                  .where((place) => place != null) // null이 아닌 항목만 필터링
                  .cast<Place>() // 타입 안전하게 캐스팅
                  .toList();

          // 거리 순으로 정렬
          places.sort((a, b) => a.distance.compareTo(b.distance));
        } else {
          // API 오류 처리
          _showErrorDialog('주변 장소 검색 API 오류: ${data['status']}');

          // 백업: 테스트 데이터 사용
          places = _getTestPlaces();

          // 테스트 데이터도 거리 순으로 정렬
          places.sort((a, b) => a.distance.compareTo(b.distance));
        }
      } else {
        // 네트워크 오류 처리
        _showErrorDialog('주변 장소 검색 네트워크 오류: ${response.statusCode}');

        // 백업: 테스트 데이터 사용
        places = _getTestPlaces();

        // 테스트 데이터도 거리 순으로 정렬
        places.sort((a, b) => a.distance.compareTo(b.distance));
      }

      setState(() {
        _nearbyPlaces = places;

        // 장소 마커 추가
        for (var place in places) {
          _markers.add(
            Marker(
              markerId: MarkerId(place.id),
              position: place.location,
              infoWindow: InfoWindow(
                title: place.name,
                snippet: '거리: ${place.distance.toStringAsFixed(0)}m',
              ),
              onTap: () {
                setState(() {
                  _selectedPlace = place;
                });
              },
              // 장소 유형에 따라 마커 색상 다르게 설정
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _currentPlaceType == 'library'
                    ? BitmapDescriptor
                        .hueRed // 도서관은 빨간색
                    : BitmapDescriptor.hueGreen, // 공원은 녹색
              ),
            ),
          );
        }

        _isLoading = false;
      });
    } catch (e) {
     
      _showErrorDialog('주변 장소를 검색하는 중 오류가 발생했습니다.');

      // 오류 발생 시 테스트 데이터 사용
      final places = _getTestPlaces();

      // 테스트 데이터도 거리 순으로 정렬
      places.sort((a, b) => a.distance.compareTo(b.distance));

      setState(() {
        _nearbyPlaces = places;

        // 장소 마커 추가
        for (var place in places) {
          _markers.add(
            Marker(
              markerId: MarkerId(place.id),
              position: place.location,
              infoWindow: InfoWindow(
                title: place.name,
                snippet: '거리: ${place.distance.toStringAsFixed(0)}m',
              ),
              onTap: () {
                setState(() {
                  _selectedPlace = place;
                });
              },
              // 장소 유형에 따라 마커 색상 다르게 설정
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _currentPlaceType == 'library'
                    ? BitmapDescriptor
                        .hueRed // 도서관은 빨간색
                    : BitmapDescriptor.hueGreen, // 공원은 녹색
              ),
            ),
          );
        }

        _isLoading = false;
      });
    }
  }

  // 테스트용 장소 데이터 생성
  List<Place> _getTestPlaces() {
    if (_currentPosition == null) return [];

    final rnd = Random();

    if (_currentPlaceType == 'library') {
      return [
        Place(
          id: '4',
          name: '중앙 도서관',
          location: LatLng(
            _currentPosition!.latitude + 0.001,
            _currentPosition!.longitude + 0.002,
          ),
          distance: 280.0 + rnd.nextInt(300).toDouble(),
        ),
        Place(
          id: '5',
          name: '구립 문화 도서관',
          location: LatLng(
            _currentPosition!.latitude - 0.0015,
            _currentPosition!.longitude - 0.001,
          ),
          distance: 350.0 + rnd.nextInt(200).toDouble(),
        ),
        Place(
          id: '6',
          name: '디지털 도서관',
          location: LatLng(
            _currentPosition!.latitude + 0.002,
            _currentPosition!.longitude - 0.0018,
          ),
          distance: 400.0 + rnd.nextInt(300).toDouble(),
        ),
      ];
    } else {
      return [
        Place(
          id: '1',
          name: '작은 공원',
          location: LatLng(
            _currentPosition!.latitude + 0.001,
            _currentPosition!.longitude + 0.001,
          ),
          distance: 250.0 + rnd.nextInt(300).toDouble(),
        ),
        Place(
          id: '2',
          name: '수완 백조 공원',
          location: LatLng(
            _currentPosition!.latitude - 0.001,
            _currentPosition!.longitude - 0.001,
          ),
          distance: 150.0 + rnd.nextInt(250).toDouble(),
        ),
        Place(
          id: '3',
          name: '장수마을 공원',
          location: LatLng(
            _currentPosition!.latitude + 0.002,
            _currentPosition!.longitude - 0.002,
          ),
          distance: 300.0 + rnd.nextInt(400).toDouble(),
        ),
      ];
    }
  }

  // 두 지점 간 거리 계산 (Haversine 공식)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000; // 지구 반지름 (미터)
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a =
        sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // 미터 단위 거리
  }

  // 길찾기 표시
  Future<void> _showDirections(Place place) async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
      _polylines.clear();
      _selectedPlace = place;
    });

    try {
      PolylinePoints polylinePoints = PolylinePoints();
      List<LatLng> polylineCoordinates = [];

      try {
        // Directions API 사용
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: ApiConstants.googleMapsApiKey,
          request: PolylineRequest(
            origin: PointLatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            destination: PointLatLng(
              place.location.latitude,
              place.location.longitude,
            ),
            mode: TravelMode.walking,
          ),
        );

        if (result.points.isNotEmpty) {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
         
        } else {
          // API 결과가 없는 경우 직선 경로 사용
         
          polylineCoordinates = _getDirectLine(place);
        }
      } catch (e) {
        // 예외 발생시 직선 경로 사용
       
        polylineCoordinates = _getDirectLine(place);
        // 사용자에게 알림
        Toast(context, '경로를 찾을 수 없어 직선 경로로 표시합니다.');
      }

      // 폴리라인 생성
      PolylineId id = const PolylineId('route');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 5,
      );

      setState(() {
        _polylines[id] = polyline;
        _isLoading = false;
      });

      // 지도 카메라를 경로가 모두 보이도록 조정
      if (polylineCoordinates.isNotEmpty) {
        LatLngBounds bounds = _boundsFromLatLngList(polylineCoordinates);
        _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    } catch (e) {
     

      // 오류 발생 시 직선 경로 대신 표시
      final polylineCoordinates = _getDirectLine(place);

      PolylineId id = const PolylineId('route');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 5,
      );

      setState(() {
        _polylines[id] = polyline;
        _isLoading = false;
      });

      // 지도 카메라를 경로가 모두 보이도록 조정
      LatLngBounds bounds = _boundsFromLatLngList(polylineCoordinates);
      _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));

      // 사용자에게 알림
      Toast(context, '경로를 찾을 수 없어 직선 경로로 표시합니다.');
    }
  }

  // 직선 경로 생성 (API 오류 시 대체용)
  List<LatLng> _getDirectLine(Place place) {
    if (_currentPosition == null) return [];

    final start = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    final end = LatLng(place.location.latitude, place.location.longitude);

    // 중간 지점을 더 많이 생성하여 자연스러운 경로 생성
    List<LatLng> points = [];
    points.add(start);

    // 중간 포인트 개수 (거리에 따라 조정)
    final distance = _calculateDistance(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );

    // 거리에 비례하여 중간 지점 개수 설정
    int segments = (distance / 200).round();
    segments = segments.clamp(3, 15);

    for (int i = 1; i < segments; i++) {
      double fraction = i / segments;

      // 시작점과 끝점 사이의 중간점 계산
      double lat = start.latitude + (end.latitude - start.latitude) * fraction;
      double lng =
          start.longitude + (end.longitude - start.longitude) * fraction;

      // 자연스러운 곡선을 위한 약간의 랜덤 편차 추가
      if (i > 1 && i < segments - 1) {
        final rnd = Random();
        double offsetFactor = 0.0001; // 편차 크기
        lat += (rnd.nextDouble() - 0.5) * offsetFactor;
        lng += (rnd.nextDouble() - 0.5) * offsetFactor;
      }

      points.add(LatLng(lat, lng));
    }

    points.add(end);
    return points;
  }

  // 좌표 목록에서 경계 계산
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  // 지도 초기화
  void _clearMap() {
    setState(() {
      _polylines.clear();
      _markers.removeWhere(
        (marker) => marker.markerId.value != 'currentLocation',
      );
      _selectedPlace = null;

      if (_currentPosition != null) {
        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              zoom: 15,
            ),
          ),
        );
      }
    });
  }

  // arguments 처리 메소드
  void _processArguments() {
    try {
      final RouteSettings? settings = ModalRoute.of(context)?.settings;
      if (settings != null && settings.arguments != null) {
        final args = settings.arguments as Map<String, dynamic>;
        final placeType = args['placeType'] as String?;
        final showList = args['showList'] as bool? ?? false;

        if (placeType != null &&
            (placeType == 'park' || placeType == 'library')) {
          setState(() {
            _currentPlaceType = placeType;
            _isPlacesVisible = showList; // 목록 자동 표시 여부 설정
            // 항상 목록 초기화
            _nearbyPlaces = [];
          });

          // 특정 도서관으로 길찾기인 경우
          final targetLibrary = args['targetLibrary'] as Map<String, dynamic>?;
          if (targetLibrary != null) {
            // 도서관 위치로 마커 추가
            final libraryId = targetLibrary['id'] as String;
            final libraryName = targetLibrary['name'] as String;
            final libraryLat = targetLibrary['lat'] as double;
            final libraryLng = targetLibrary['lng'] as double;

            // 현재 위치가 있고 목표 도서관 정보가 있으면 바로 길찾기 표시
            if (_currentPosition != null) {
              // 도서관 마커 추가
              final targetLocation = LatLng(libraryLat, libraryLng);
              setState(() {
                // 장소 선택 설정
                _selectedPlace = Place(
                  id: libraryId,
                  name: libraryName,
                  location: targetLocation,
                  distance: _calculateDistance(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                    libraryLat,
                    libraryLng,
                  ),
                );

                // 마커 추가
                _markers.add(
                  Marker(
                    markerId: MarkerId(libraryId),
                    position: targetLocation,
                    infoWindow: InfoWindow(title: libraryName, snippet: '도서관'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedPlace = _selectedPlace;
                      });
                    },
                  ),
                );
              });

              // 길찾기 실행
              _showDirections(_selectedPlace!);
            }
          } else {
            // 위치가 있으면 바로 검색 시작
            if (_currentPosition != null && _isPlacesVisible) {
              _searchNearbyPlaces();
            }
          }
        }
      }
    } catch (e) {
    
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '지도',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
            tooltip: '위치 새로고침',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 지도 위젯
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.5665, 126.9780), // 서울 초기 위치
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            polylines: Set<Polyline>.of(_polylines.values),
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _controller = controller;
              });
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 15,
                    ),
                  ),
                );
              }
              _setMapStyle();
             
            },
          ),

          // 로딩 인디케이터
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // 하단 패널 - 장소 목록 또는 선택 정보
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_selectedPlace != null)
                  _buildPlaceDetailCard()
                else if (_isPlacesVisible)
                  _buildPlacesList(),

                // 버튼 메뉴
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        // 도서관 목록 버튼
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // 현재 보여지고 있는 목록이 있고, 현재 타입과 같으면 닫기
                                if (_isPlacesVisible &&
                                    _currentPlaceType == 'library') {
                                  _isPlacesVisible = false;
                                } else {
                                  // 도서관 목록 표시
                                  _currentPlaceType = 'library';
                                  _isPlacesVisible = true;
                                  // 장소 목록 초기화
                                  _nearbyPlaces = [];
                                  // 항상 새로 검색
                                  if (_currentPosition != null) {
                                    _searchNearbyPlaces();
                                  }
                                }
                                _selectedPlace = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  (_currentPlaceType == 'library' &&
                                          _isPlacesVisible)
                                      ? Colors.grey.shade400
                                      : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _currentPlaceType == 'library' &&
                                          _isPlacesVisible
                                      ? Icons.close
                                      : Icons.local_library,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _currentPlaceType == 'library' &&
                                          _isPlacesVisible
                                      ? '목록 닫기'
                                      : '도서관 목록',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 공원 목록 버튼
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // 현재 보여지고 있는 목록이 있고, 현재 타입과 같으면 닫기
                                if (_isPlacesVisible &&
                                    _currentPlaceType == 'park') {
                                  _isPlacesVisible = false;
                                } else {
                                  // 공원 목록 표시
                                  _currentPlaceType = 'park';
                                  _isPlacesVisible = true;
                                  // 장소 목록 초기화
                                  _nearbyPlaces = [];
                                  // 항상 새로 검색
                                  if (_currentPosition != null) {
                                    _searchNearbyPlaces();
                                  }
                                }
                                _selectedPlace = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  (_currentPlaceType == 'park' &&
                                          _isPlacesVisible)
                                      ? Colors.grey.shade400
                                      : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _currentPlaceType == 'park' &&
                                          _isPlacesVisible
                                      ? Icons.close
                                      : Icons.park,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _currentPlaceType == 'park' &&
                                          _isPlacesVisible
                                      ? '목록 닫기'
                                      : '공원 목록',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 초기화 버튼
                        SizedBox(
                          width: 80,
                          child: ElevatedButton(
                            onPressed: _clearMap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '초기화',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 내 위치 버튼 - 앱바 아래 우측에 위치
          Positioned(
            top: 40, // 앱바 아래 여유있게 위치
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _getCurrentLocation,
                backgroundColor: Colors.white,
                mini: true, // 작은 크기의 버튼
                child: const Icon(Icons.my_location, color: Colors.blue),
                tooltip: '내 위치',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 장소 목록 위젯
  Widget _buildPlacesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      height: 250,
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _placeTypeText[_currentPlaceType] ?? '주변 장소',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '총 ${_nearbyPlaces.length}개',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
          Expanded(
            child:
                _nearbyPlaces.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _currentPlaceType == 'library'
                                ? Icons.local_library
                                : Icons.park,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '주변에 표시할 ${_currentPlaceType == 'library' ? '도서관' : '공원'}이 없습니다',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _nearbyPlaces.length,
                      itemBuilder: (context, index) {
                        final place = _nearbyPlaces[index];
                        return PlaceListItem(
                          place: place,
                          onTap: () {
                            _showDirections(place);
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // 선택된 장소 상세 카드
  Widget _buildPlaceDetailCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _currentPlaceType == 'library'
                    ? Icons.local_library
                    : Icons.park,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedPlace!.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.directions_walk, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '거리: ${_selectedPlace!.distance.toStringAsFixed(0)}m',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showDirections(_selectedPlace!),
                icon: const Icon(Icons.directions_walk, size: 20),
                label: const Text('길찾기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedPlace = null;
                  });
                },
                icon: const Icon(Icons.close, size: 20),
                label: const Text('닫기'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 장소 정보 클래스
class Place {
  final String id;
  final String name;
  final LatLng location;
  final double distance;

  Place({
    required this.id,
    required this.name,
    required this.location,
    required this.distance,
  });
}
