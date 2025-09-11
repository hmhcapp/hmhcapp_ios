// lib/models/quote.dart
class Quote {
  final String id;
  final String categoryTitle;

  final String distributor;
  final String name;
  final String company;
  final String email;
  final String telephone;
  final String postcode;

  final String projectName;
  final String projectStage;
  final String itemsNeededDate;

  final String additionalInfo;

  /// Storage path (e.g. QUOTE_DATA/{id}/plan.jpg) or null
  final String? imageUrl;

  /// Unix millis
  final int timestamp;

  /// Firebase Auth UID of the submitter
  final String? userId;

  /// Soft delete flag
  final bool deleted;

  const Quote({
    required this.id,
    required this.categoryTitle,
    this.distributor = '',
    this.name = '',
    this.company = '',
    this.email = '',
    this.telephone = '',
    this.postcode = '',
    this.projectName = '',
    this.projectStage = '',
    this.itemsNeededDate = '',
    this.additionalInfo = '',
    this.imageUrl,
    required this.timestamp,
    this.userId,
    this.deleted = false,
  });

  Quote copyWith({
    String? id,
    String? categoryTitle,
    String? distributor,
    String? name,
    String? company,
    String? email,
    String? telephone,
    String? postcode,
    String? projectName,
    String? projectStage,
    String? itemsNeededDate,
    String? additionalInfo,
    String? imageUrl,
    int? timestamp,
    String? userId,
    bool? deleted,
  }) {
    return Quote(
      id: id ?? this.id,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      distributor: distributor ?? this.distributor,
      name: name ?? this.name,
      company: company ?? this.company,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      postcode: postcode ?? this.postcode,
      projectName: projectName ?? this.projectName,
      projectStage: projectStage ?? this.projectStage,
      itemsNeededDate: itemsNeededDate ?? this.itemsNeededDate,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      deleted: deleted ?? this.deleted,
    );
  }
}
