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
import 'package:buds/config/environment.dart';
import 'package:buds/services/location_service.dart';
import 'widgets/place_list_item.dart';

// Google API 키
// const String GOOGLE_API_KEY = 'AIzaSyCqWmOBMgV6W2vUMeEAtc-Q3nJVYA4wp_4';

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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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
      
    } catch (e) {
      debugPrint('위치 가져오기 오류: $e');
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
      debugPrint('맵 스타일 적용 성공');
    } catch (e) {
      debugPrint('맵 스타일 적용 오류: $e');
    }
  }

  // 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      _markers.removeWhere((marker) => marker.markerId.value != 'currentLocation');
    });

    try {
      // Places API를 사용하여 주변 공원 검색
      final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
        'location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        '&radius=1500&type=park&key=${Environment.googleMapsApiKey}'
      ));
      
      List<Place> places = [];
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Places API 응답: $data');
        
        if (data['status'] == 'OK') {
          places = (data['results'] as List).map((place) {
            final lat = place['geometry']['location']['lat'];
            final lng = place['geometry']['location']['lng'];
            final distance = _calculateDistance(
              _currentPosition!.latitude, 
              _currentPosition!.longitude,
              lat,
              lng,
            );
            
            return Place(
              id: place['place_id'],
              name: place['name'],
              location: LatLng(lat, lng),
              distance: distance,
            );
          }).toList();
        } else {
          // API 오류 처리
          _showErrorDialog('주변 장소 검색 API 오류: ${data['status']}');
          
          // 백업: 테스트 데이터 사용
          places = _getTestPlaces();
        }
      } else {
        // 네트워크 오류 처리
        _showErrorDialog('주변 장소 검색 네트워크 오류: ${response.statusCode}');
        
        // 백업: 테스트 데이터 사용
        places = _getTestPlaces();
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
            ),
          );
        }
        
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('주변 장소 검색 오류: $e');
      _showErrorDialog('주변 장소를 검색하는 중 오류가 발생했습니다.');
      
      // 오류 발생 시 테스트 데이터 사용
      final places = _getTestPlaces();
      
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
    return [
      Place(
        id: '1',
        name: '작은 공원',
        location: LatLng(_currentPosition!.latitude + 0.001, _currentPosition!.longitude + 0.001),
        distance: 250.0 + rnd.nextInt(300).toDouble(),
      ),
      Place(
        id: '2',
        name: '수완 백조 공원',
        location: LatLng(_currentPosition!.latitude - 0.001, _currentPosition!.longitude - 0.001),
        distance: 150.0 + rnd.nextInt(250).toDouble(),
      ),
      Place(
        id: '3',
        name: '장수마을 공원',
        location: LatLng(_currentPosition!.latitude + 0.002, _currentPosition!.longitude - 0.002),
        distance: 300.0 + rnd.nextInt(400).toDouble(),
      ),
    ];
  }

  // 두 지점 간 거리 계산 (Haversine 공식)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // 지구 반지름 (미터)
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
              cos(phi1) * cos(phi2) *
              sin(deltaLambda / 2) * sin(deltaLambda / 2);
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
      
      // Directions API 사용
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: Environment.googleMapsApiKey,
        request: PolylineRequest(
          origin: PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          destination: PointLatLng(place.location.latitude, place.location.longitude),
          mode: TravelMode.walking,
        ),
      );
      
      List<LatLng> polylineCoordinates = [];
      
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        // API 결과가 없는 경우 직선 경로 사용
        debugPrint('길찾기 결과 없음: ${result.errorMessage}');
        polylineCoordinates = _getDirectLine(place);
      }

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
    } catch (e) {
      debugPrint('길찾기 오류: $e');
      _showErrorDialog('길찾기 정보를 가져오는 중 오류가 발생했습니다.');
      
      // 오류 발생 시 직선 경로 사용
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
    }
  }
  
  // 직선 경로 생성 (API 오류 시 대체용)
  List<LatLng> _getDirectLine(Place place) {
    if (_currentPosition == null) return [];
    
    return [
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      LatLng(
        _currentPosition!.latitude + (place.location.latitude - _currentPosition!.latitude) / 3,
        _currentPosition!.longitude + (place.location.longitude - _currentPosition!.longitude) / 3,
      ),
      LatLng(
        _currentPosition!.latitude + 2 * (place.location.latitude - _currentPosition!.latitude) / 3,
        _currentPosition!.longitude + 2 * (place.location.longitude - _currentPosition!.longitude) / 3,
      ),
      LatLng(place.location.latitude, place.location.longitude),
    ];
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
      _markers.removeWhere((marker) => marker.markerId.value != 'currentLocation');
      _selectedPlace = null;
      
      if (_currentPosition != null) {
        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 15,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지도'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      zoom: 15,
                    ),
                  ),
                );
              }
              _setMapStyle();
              debugPrint('Google 지도 생성 완료');
            },
          ),
          
          // 로딩 인디케이터
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
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
                  padding: const EdgeInsets.all(8.0),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isPlacesVisible = !_isPlacesVisible;
                              if (_isPlacesVisible && _nearbyPlaces.isEmpty && _currentPosition != null) {
                                _searchNearbyPlaces();
                              }
                              _selectedPlace = null;
                            });
                          },
                          icon: Icon(_isPlacesVisible ? Icons.close : Icons.park),
                          label: Text(_isPlacesVisible ? '닫기' : '주변 공원'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _clearMap,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('초기화'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
        tooltip: '내 위치',
      ),
    );
  }

  // 장소 목록 위젯
  Widget _buildPlacesList() {
    return Container(
      color: Colors.white.withOpacity(0.9),
      height: 200,
      child: _nearbyPlaces.isEmpty
          ? const Center(child: Text('주변 공원이 없습니다'))
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
    );
  }

  // 선택된 장소 상세 카드
  Widget _buildPlaceDetailCard() {
    return Container(
      color: Colors.white.withOpacity(0.9),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedPlace!.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('거리: ${_selectedPlace!.distance.toStringAsFixed(0)}m'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showDirections(_selectedPlace!),
                icon: const Icon(Icons.directions_walk),
                label: const Text('길찾기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedPlace = null;
                  });
                },
                icon: const Icon(Icons.close),
                label: const Text('닫기'),
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