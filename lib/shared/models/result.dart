// ignore_for_file: public_member_api_docs, sort_constructors_first
class Result {
  final String path;
  final String name;
  final int size;
  final double percentage;

  Result({
    required this.path,
    required this.name,
    required this.size,
    required this.percentage,
  });

  Result copyWith({String? path, String? name, int? size, double? percentage}) {
    return Result(
      path: path ?? this.path,
      name: name ?? this.name,
      size: size ?? this.size,
      percentage: percentage ?? this.percentage,
    );
  }
}

class Log {
  final String log;
  final bool okay;
  final DateTime createdAt;

  Log({required this.log, required this.createdAt, required this.okay});

  Log copyWith({String? log, DateTime? createdAt, bool? okay}) {
    return Log(
      log: log ?? this.log,
      createdAt: createdAt ?? this.createdAt,
      okay: okay ?? this.okay,
    );
  }
}
