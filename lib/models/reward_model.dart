// models/reward_model.dart

class Reward {
  final String name;
  final int cost;
  final String? imageUrl;

  Reward({
    required this.name,
    required this.cost,
    this.imageUrl,
  });

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      name: map['name'] ?? '이름 없음',
      cost: map['cost'] ?? 0,
      imageUrl: map['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cost': cost,
      'image_url': imageUrl,
    };
  }
}
