/*
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'app_exceptions.dart';

class ErrorHandler {
  static AppException handle(dynamic error) {

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException("Connection timeout, please try again.");

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 500;
          final message = error.response?.data?["message"] ?? "Server error";

          if (statusCode == 400) return ValidationException(message);
          if (statusCode == 401) return ValidationException("Unauthorized");
          if (statusCode == 404) return ServerException("Resource not found");

          return ServerException(message);
        case DioExceptionType.cancel:return AppException(" Request cancelled");

        case DioExceptionType.badCertificate:
          return AppException(" Bad SSL Certificate");

        default:
          return NetworkException("Failed to connect to server");
      }
    }
    else if (error is TimeoutException) {
      return NetworkException("Connection timeout, please try again.");
    }
    else if (error is SocketException) {
      return NetworkException(" No Internet connection");
    }
    else {
      return AppException("Unexpected error occurred: ${error.toString()}");
    }
  }
}
*/
