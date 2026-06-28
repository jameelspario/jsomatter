class CloudJson {
  final String id;
  final String name;
  final String content;
  final DateTime updatedAt;
  final int size;

  CloudJson({
    required this.id,
    required this.name,
    required this.content,
    required this.updatedAt,
    required this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'updatedAt': updatedAt.toIso8601String(),
      'size': size,
    };
  }

  factory CloudJson.fromMap(Map<String, dynamic> map) {
    return CloudJson(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      content: map['content'] ?? '',
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      size: map['size'] ?? 0,
    );
  }
}
