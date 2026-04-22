class ReciterModel {
  ReciterModel({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    return ReciterModel(
      id: int.tryParse('${json['id'] ?? json['reciter_id'] ?? 0}') ?? 0,
      name: (json['name'] ?? json['reciter_name'] ?? json['reciter_short_name'] ?? 'Unknown').toString(),
    );
  }
}
