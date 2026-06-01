class Appliance {
  final int id;
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
    id: int.parse('${json['id']}'),
    name: '${json['name'] ?? ''}',
    category: json['category']?.toString(),
    description: json['description']?.toString(),
    imageUrl: json['image_url']?.toString(),
  );
}
