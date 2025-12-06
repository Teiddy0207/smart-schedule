class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;

  factory ApiException.fromDioError(dynamic error) {
    if (error.response != null) {
      // Server responded with error status
      final statusCode = error.response?.statusCode;
      final message = error.response?.data?['message'] ?? 
                     error.response?.data?['error'] ?? 
                     'Đã xảy ra lỗi từ server';
      
      return ApiException(
        message: message,
        statusCode: statusCode,
        originalError: error,
      );
    } else if (error.request != null) {
      // Request was made but no response received
      return ApiException(
        message: 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
        originalError: error,
      );
    } else {
      // Something else happened
      return ApiException(
        message: 'Đã xảy ra lỗi không xác định',
        originalError: error,
      );
    }
  }
}

