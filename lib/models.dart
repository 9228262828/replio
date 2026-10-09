enum StockStatus { good, low, refillNow, out }

const replioCategories = <String>[
  'Kitchen',
  'Bathroom',
  'Cleaning',
  'Food',
  'Pets',
  'Office',
  'Other',
];

const replioUnits = <String>[
  'pcs',
  'bottles',
  'packs',
  'kg',
  'g',
  'L',
  'ml',
  'boxes',
  'rolls',
];

class RefillItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final double minimumQuantity;
  final String unit;
  final DateTime lastRefillDate;
  final String notes;
  final bool favorite;

  const RefillItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minimumQuantity,
    required this.unit,
    required this.lastRefillDate,
    required this.notes,
    required this.favorite,
  });

  StockStatus get status {
    if (quantity <= 0) return StockStatus.out;
    if (quantity <= minimumQuantity) return StockStatus.refillNow;
    if (quantity <= minimumQuantity * 1.5) return StockStatus.low;
    return StockStatus.good;
  }

  RefillItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    double? minimumQuantity,
    String? unit,
    DateTime? lastRefillDate,
    String? notes,
    bool? favorite,
  }) {
    return RefillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      unit: unit ?? this.unit,
      lastRefillDate: lastRefillDate ?? this.lastRefillDate,
      notes: notes ?? this.notes,
      favorite: favorite ?? this.favorite,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'minimumQuantity': minimumQuantity,
        'unit': unit,
        'lastRefillDate': lastRefillDate.toIso8601String(),
        'notes': notes,
        'favorite': favorite,
      };

  factory RefillItem.fromMap(Map<String, dynamic> map) {
    return RefillItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      minimumQuantity: (map['minimumQuantity'] as num?)?.toDouble() ?? 1,
      unit: map['unit'] as String? ?? 'pcs',
      lastRefillDate: DateTime.tryParse(
            map['lastRefillDate'] as String? ?? '',
          ) ??
          DateTime.now(),
      notes: map['notes'] as String? ?? '',
      favorite: map['favorite'] as bool? ?? false,
    );
  }
}

class RefillEvent {
  final String id;
  final String itemId;
  final String itemName;
  final double addedQuantity;
  final String unit;
  final DateTime date;

  const RefillEvent({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.addedQuantity,
    required this.unit,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'itemId': itemId,
        'itemName': itemName,
        'addedQuantity': addedQuantity,
        'unit': unit,
        'date': date.toIso8601String(),
      };

  factory RefillEvent.fromMap(Map<String, dynamic> map) {
    return RefillEvent(
      id: map['id'] as String? ?? '',
      itemId: map['itemId'] as String? ?? '',
      itemName: map['itemName'] as String? ?? '',
      addedQuantity: (map['addedQuantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'pcs',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
