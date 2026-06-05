class Appliance {
  final String id;
  final String name;
  final String? category;
  final String? description;
  final String? imageUrl;

  const Appliance({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.imageUrl,
  });

  factory Appliance.fromJson(Map<String, dynamic> json) => Appliance(
    id: '${json['id'] ?? ''}',
    name: '${json['name'] ?? ''}',
    category: json['category']?.toString(),
    description: json['description']?.toString(),
    imageUrl: json['image_url']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'description': description,
    'image_url': imageUrl,
  };
}
