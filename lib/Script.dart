class Script {
  final String title;
  final DateTime date;
  final DateTime latestdate;

  Script({
    required this.title,
    required this.date,
    required this.latestdate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'latestdate': latestdate.toIso8601String(),
    };
  }

  factory Script.fromJson(Map<String, dynamic> json) {
    return Script(
      title: json['title'],
      date: DateTime.parse(json['date']),
      latestdate: DateTime.parse(json['latestdate']),
    );
  }
}
