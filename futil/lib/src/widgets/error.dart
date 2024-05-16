class CommonException implements Exception {
  final String message;

  CommonException({this.message = "未知错误"});

  @override
  String toString() {
    return message;
  }
}

class CommonCancelException implements Exception {
  final String message;

  CommonCancelException({this.message = "取消"});

  @override
  String toString() {
    return message;
  }
}
