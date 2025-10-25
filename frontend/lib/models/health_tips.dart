class HealthTips {
  final int id;
  final String title;
  final String content;
  final String dateRecorded;

  // constructor - required fields
  HealthTips({
    required this.id,
    required this.title,
    required this.content,
    required this.dateRecorded,
  });

  // create clinics object from JSON data
  factory HealthTips.fromJson(Map<String, dynamic> json) {
    return HealthTips(
      id: json['id'], 
      title: json['title'], 
      content: json['content'],
      dateRecorded: json['created_at'] ?? '',
    );
  }

  // convert clinics object to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': dateRecorded,
    };
  }
}