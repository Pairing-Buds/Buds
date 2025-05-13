import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수를 관리하는 클래스
class Environment {
  /// Google Maps API 키
  static String get googleMapsApiKey {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'AIzaSyCqWmOBMgV6W2vUMeEAtc-Q3nJVYA4wp_4';
  }
  
  /// API 기본 URL
  static String get apiUrl {
    return dotenv.env['API_URL'] ?? 'https://api.example.com';
  }
} 