import 'package:dio/dio.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/',
      headers: {
        'Accept': 'application/json',
      },
    ),
  );
}
