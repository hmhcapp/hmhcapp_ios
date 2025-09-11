// lib/models/warranty.dart
class Warranty {
  final String id;
  final String userId;
  final int timestamp;

  // Installer
  final String installerName;
  final String installerCompany;
  final String installerPhone;

  // Customer
  final String customerName;
  final String customerEmail;
  final String customerAddress;
  final String customerPostcode;

  // Product
  final String productType;     // e.g. "Underfloor Heating" | "Frost Protection"
  final String productDetails;  // e.g. "PKM-160 heating mats"
  final List<String> roomTypes; // applicable for UFH only
  final String floorArea;       // e.g., "15m²"

  // Electrical
  final String electricalCertifier;
  final String rcdFitted; // "Yes" | "No"

  // Purchase
  final String purchaseDate;     // dd/MM/yyyy
  final String installationDate; // dd/MM/yyyy
  final String wherePurchased;
  final String invoiceNumber;

  // PDF
  final String? pdfUrl;          // Download URL (filled by CF)
  final String? pdfStoragePath;  // e.g. CREATED_WARRANTY_PDF/{id}.pdf

  // Soft delete
  final bool deleted;

  const Warranty({
    required this.id,
    required this.userId,
    required this.timestamp,

    required this.installerName,
    required this.installerCompany,
    required this.installerPhone,

    required this.customerName,
    required this.customerEmail,
    required this.customerAddress,
    required this.customerPostcode,

    required this.productType,
    required this.productDetails,
    required this.roomTypes,
    required this.floorArea,

    required this.electricalCertifier,
    required this.rcdFitted,

    required this.purchaseDate,
    required this.installationDate,
    required this.wherePurchased,
    required this.invoiceNumber,

    this.pdfUrl,
    this.pdfStoragePath,
    this.deleted = false,
  });

  Warranty copyWith({
    String? id,
    String? userId,
    int? timestamp,
    String? installerName,
    String? installerCompany,
    String? installerPhone,
    String? customerName,
    String? customerEmail,
    String? customerAddress,
    String? customerPostcode,
    String? productType,
    String? productDetails,
    List<String>? roomTypes,
    String? floorArea,
    String? electricalCertifier,
    String? rcdFitted,
    String? purchaseDate,
    String? installationDate,
    String? wherePurchased,
    String? invoiceNumber,
    String? pdfUrl,
    String? pdfStoragePath,
    bool? deleted,
  }) {
    return Warranty(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      installerName: installerName ?? this.installerName,
      installerCompany: installerCompany ?? this.installerCompany,
      installerPhone: installerPhone ?? this.installerPhone,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerAddress: customerAddress ?? this.customerAddress,
      customerPostcode: customerPostcode ?? this.customerPostcode,
      productType: productType ?? this.productType,
      productDetails: productDetails ?? this.productDetails,
      roomTypes: roomTypes ?? this.roomTypes,
      floorArea: floorArea ?? this.floorArea,
      electricalCertifier: electricalCertifier ?? this.electricalCertifier,
      rcdFitted: rcdFitted ?? this.rcdFitted,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      installationDate: installationDate ?? this.installationDate,
      wherePurchased: wherePurchased ?? this.wherePurchased,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      pdfStoragePath: pdfStoragePath ?? this.pdfStoragePath,
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp,

      'installerName': installerName,
      'installerCompany': installerCompany,
      'installerPhone': installerPhone,

      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerAddress': customerAddress,
      'customerPostcode': customerPostcode,

      'productType': productType,
      'productDetails': productDetails,
      'roomTypes': roomTypes,
      'floorArea': floorArea,

      'electricalCertifier': electricalCertifier,
      'rcdFitted': rcdFitted,

      'purchaseDate': purchaseDate,
      'installationDate': installationDate,
      'wherePurchased': wherePurchased,
      'invoiceNumber': invoiceNumber,

      'pdfUrl': pdfUrl,
      'pdfStoragePath': pdfStoragePath,

      'deleted': deleted,
    };
  }

  factory Warranty.fromMap(Map<String, dynamic> m) {
    return Warranty(
      id: (m['id'] ?? '').toString(),
      userId: (m['userId'] ?? '').toString(),
      timestamp: (m['timestamp'] is int)
          ? m['timestamp'] as int
          : DateTime.now().millisecondsSinceEpoch,

      installerName: (m['installerName'] ?? '').toString(),
      installerCompany: (m['installerCompany'] ?? '').toString(),
      installerPhone: (m['installerPhone'] ?? '').toString(),

      customerName: (m['customerName'] ?? '').toString(),
      customerEmail: (m['customerEmail'] ?? '').toString(),
      customerAddress: (m['customerAddress'] ?? '').toString(),
      customerPostcode: (m['customerPostcode'] ?? '').toString(),

      productType: (m['productType'] ?? '').toString(),
      productDetails: (m['productDetails'] ?? '').toString(),
      roomTypes: (m['roomTypes'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      floorArea: (m['floorArea'] ?? '').toString(),

      electricalCertifier: (m['electricalCertifier'] ?? '').toString(),
      rcdFitted: (m['rcdFitted'] ?? '').toString(),

      purchaseDate: (m['purchaseDate'] ?? '').toString(),
      installationDate: (m['installationDate'] ?? '').toString(),
      wherePurchased: (m['wherePurchased'] ?? '').toString(),
      invoiceNumber: (m['invoiceNumber'] ?? '').toString(),

      pdfUrl: (m['pdfUrl'] as String?),
      pdfStoragePath: (m['pdfStoragePath'] as String?),

      deleted: (m['deleted'] as bool?) ?? false,
    );
  }
}
