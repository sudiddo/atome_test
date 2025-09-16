class Category {
  final int? id;
  final String name;

  const Category({
    this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Tag {
  final int? id;
  final String name;

  const Tag({
    this.id,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Pet {
  final int? id;
  final String name;
  final String status;
  final List<String> photoUrls;
  final Category? category;
  final List<Tag>? tags;

  const Pet({
    this.id,
    required this.name,
    this.status = 'available',
    this.photoUrls = const [],
    this.category,
    this.tags,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'available',
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'photoUrls': photoUrls,
      if (category != null) 'category': category!.toJson(),
      if (tags != null) 'tags': tags!.map((e) => e.toJson()).toList(),
    };
  }

  Pet copyWith({
    int? id,
    String? name,
    String? status,
    List<String>? photoUrls,
    Category? category,
    List<Tag>? tags,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      photoUrls: photoUrls ?? this.photoUrls,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }
}