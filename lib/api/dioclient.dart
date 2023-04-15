import 'package:dio/dio.dart';

Dio dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 500000),
  receiveTimeout: const Duration(seconds: 500000),
));
