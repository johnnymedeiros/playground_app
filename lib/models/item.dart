class Item {
  final String id;
  final String title;
  final String description;

  const Item({
    required this.id,
    required this.title,
    required this.description,
  });

  Item copyWith({
    String? id,
    String? title,
    String? description,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}