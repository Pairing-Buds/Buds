// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// Project imports:
import 'package:buds/config/environment.dart';

/// 위치 서비스 클래스
/// 위치 권한 요청, 현재 위치 가져오기, 주변 장소 검색 등의 기능을 제공합니다.
class LocationService {
  // API 키 (환경 변수에서 가져옴)
  String get _apiKey => Environment.googleMapsApiKey;

  /// 위치 서비스 상태 확인 및 권한 요청
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// 현재 위치 가져오기
  Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('LocationService: 현재 위치 가져오기 오류 - $e');
      return null;
    }
  }

  /// 주변 장소 검색
  Future<List<Map<String, dynamic>>> searchNearbyPlaces(
    double latitude,
    double longitude, {
    String type = 'park',
    int radius = 1500,
  }) async {
    // Places API 호출
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
      'location=$latitude,$longitude&radius=$radius&type=$type&key=$_apiKey'
    );
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('LocationService: Places API 응답 - ${data['status']}');
        
        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['results']);
        }
      }
      debugPrint('LocationService: Places API 오류 - ${response.statusCode}');
      return _getTestPlaces(latitude, longitude);
    } catch (e) {
      debugPrint('LocationService: 주변 장소 검색 오류 - $e');
      return _getTestPlaces(latitude, longitude);
    }
  }
  
  // 테스트용 더미 데이터
  List<Map<String, dynamic>> _getTestPlaces(double latitude, double longitude) {
    final rnd = Random();
    
    return [
      {
        'place_id': '1',
        'name': '작은 공원',
        'geometry': {
          'location': {
            'lat': latitude + 0.001,
            'lng': longitude + 0.001,
          },
        },
        'distance': 250.0 + rnd.nextInt(300).toDouble(),
      },
      {
        'place_id': '2',
        'name': '수완 백조 공원',
        'geometry': {
          'location': {
            'lat': latitude - 0.001,
            'lng': longitude - 0.001,
          },
        },
        'distance': 150.0 + rnd.nextInt(250).toDouble(),
      },
      {
        'place_id': '3',
        'name': '장수마을 공원',
        'geometry': {
          'location': {
            'lat': latitude + 0.002,
            'lng': longitude - 0.002,
          },
        },
        'distance': 300.0 + rnd.nextInt(400).toDouble(),
      },
    ];
  }

  /// 두 위치 사이의 거리 계산 (Haversine 공식)
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const R = 6371000; // 지구 반지름 (미터)
    final phi1 = startLatitude * pi / 180;
    final phi2 = endLatitude * pi / 180;
    final deltaPhi = (endLatitude - startLatitude) * pi / 180;
    final deltaLambda = (endLongitude - startLongitude) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // 미터 단위 거리
  }

  /// 경로 가져오기
  Future<List<LatLng>> getRouteBetweenPoints(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    // Directions API 호출
    try {
      final polylinePoints = PolylinePoints();
      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: _apiKey,
        request: PolylineRequest(
          origin: PointLatLng(startLat, startLng),
          destination: PointLatLng(endLat, endLng),
          mode: TravelMode.walking,
        ),
      );
      
      if (result.points.isNotEmpty) {
        debugPrint('LocationService: 경로 포인트 수 - ${result.points.length}');
        return result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      }
      
      debugPrint('LocationService: 경로 결과 없음 - ${result.errorMessage}');
      return _getTestRoute(startLat, startLng, endLat, endLng);
    } catch (e) {
      debugPrint('LocationService: 경로 가져오기 오류 - $e');
      return _getTestRoute(startLat, startLng, endLat, endLng);
    }
  }
  
  // 테스트용 더미 경로 데이터 (직선 경로)
  List<LatLng> _getTestRoute(double startLat, double startLng, double endLat, double endLng) {
    return [
      LatLng(startLat, startLng),
      LatLng(
        startLat + (endLat - startLat) / 3,
        startLng + (endLng - startLng) / 3,
      ),
      LatLng(
        startLat + 2 * (endLat - startLat) / 3,
        startLng + 2 * (endLng - startLng) / 3,
      ),
      LatLng(endLat, endLng),
    ];
  }
} 