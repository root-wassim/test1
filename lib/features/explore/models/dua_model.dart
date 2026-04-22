class DuaItem {
  DuaItem({
    required this.id,
    required this.text,
    required this.count,
  });

  final int id;
  final String text;
  final int count;

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    return DuaItem(
      id: (json['id'] as int?) ?? 0,
      text: (json['text'] ?? '').toString(),
      count: (json['count'] as int?) ?? 1,
    );
  }
}

class DuaCategory {
  DuaCategory({required this.key, required this.label, required this.icon, required this.items});

  final String key;
  final String label;
  final String icon;
  final List<DuaItem> items;
}
