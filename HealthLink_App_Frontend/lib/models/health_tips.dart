class HealthTips {
  final int id;
  final String title;
  final String content;
  final DateTime dateRecorded;
  final String category; 

  // constructor - required fields
  HealthTips({
    required this.id,
    required this.title,
    required this.content,
    required this.dateRecorded,
    required this.category,
  });

  // create health tips object from JSON data
  factory HealthTips.fromJson(Map<String, dynamic> json) {
    return HealthTips(
      id: json['id'], 
      title: json['title'], 
      content: json['content'],
      dateRecorded: DateTime.parse(json['created_at']),
      category: json['category'] ?? 'General Wellness',
    );
  }

  // convert health tips object to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': dateRecorded.toIso8601String(),
      'category': category,
    };
  }
}