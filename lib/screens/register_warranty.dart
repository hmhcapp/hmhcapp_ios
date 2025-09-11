import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';

import '../routes.dart';

const _dark = Color(0xFF333333);
const _black = Color(0xFF000000);
const _gold = Color(0xFFF1B227);
const _white = Colors.white;
const _cardGrey = Color(0xFF6C6767);
const _labelWhite = Colors.white70;

/// Warranty data model used in Saved Warranties list rendering
class WarrantyItem {
  final String id;
  final String customerName;
  final String customerAddress;
  final String productDetails;
  final String installationDate;
  final String? pdfUrl;
  final int timestamp;

  WarrantyItem({
    required this.id,
    required this.customerName,
    required this.customerAddress,
    required this.productDetails,
    required this.installationDate,
    required this.timestamp,
    this.pdfUrl,
  });

  factory WarrantyItem.fromMap(Map<String, dynamic> m) {
    return WarrantyItem(
      id: (m['id'] ?? '').toString(),
      customerName: (m['customerName'] ?? '').toString(),
      customerAddress: (m['customerAddress'] ?? '').toString(),
      productDetails: (m['productDetails'] ?? '').toString(),
      installationDate: (m['installationDate'] ?? '').toString(),
      timestamp: (m['timestamp'] is int)
          ? m['timestamp'] as int
          : (m['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0,
      pdfUrl: m['pdfUrl'] as String?,
    );
  }
}

/// Main register warranty screen with tabs: New + Saved.
class RegisterWarrantyScreen extends StatefulWidget {
  final int initialTabIndex;
  const RegisterWarrantyScreen({super.key, this.initialTabIndex = 0});

  @override
  State<RegisterWarrantyScreen> createState() => _RegisterWarrantyScreenState();
}

class _RegisterWarrantyScreenState extends State<RegisterWarrantyScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  late TabController _tabController;

  // -------------------- Form State --------------------
  int _currentStep = 1;

  // Installer (Step 1)
  final _installerNameCtrl = TextEditingController();
  final _installerCompanyCtrl = TextEditingController();
  final _installerPhoneCtrl = TextEditingController();

  // Customer (Step 2)
  final _customerNameCtrl = TextEditingController();
  final _customerEmailCtrl = TextEditingController();
  final _customerAddressCtrl = TextEditingController();
  final _customerPostcodeCtrl = TextEditingController();

  // Product (Step 3)
  String _productType = '';
  String _productDetails = '';
  final List<String> _roomOptions = const [
    'Bathroom', 'Bedroom', 'Conservatory', 'Dining Room', 'Ensuite', 'Garden Room',
    'Hall', 'Kitchen', 'Kitchen/Diner', 'Landing', 'Living Room', 'Utility', 'Other'
  ];
  final Set<String> _selectedRooms = {};
  final _floorAreaCtrl = TextEditingController();

  // Electrical (Step 4)
  final _electricalCertifierCtrl = TextEditingController();
  String _rcdFitted = '';

  // Purchase (Step 5)
  String _purchaseDate = '';
  String _installDate = '';
  final _purchaseDateCtrl = TextEditingController();
  final _installDateCtrl = TextEditingController();
  final _wherePurchasedCtrl = TextEditingController();
  final _invoiceNumberCtrl = TextEditingController(); // optional

  bool _submitting = false;
  bool _showValidationErrors = false;

  // Scroll + Focus
  final _scrollCtrl = ScrollController();
  final _fnInstallerName = FocusNode();
  final _fnCustomerName = FocusNode();
  final _fnProductType = FocusNode();
  final _fnCertifier = FocusNode();
  final _fnWherePurchased = FocusNode();

  @override
  void initState() {
    super.initState();
    // Hide bottom navigation bar for this screen only
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );

    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _prefillInstallerFromProfile();
  }

  @override
  void dispose() {
    // Restore system UI when leaving this screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );

    _tabController.dispose();
    _installerNameCtrl.dispose();
    _installerCompanyCtrl.dispose();
    _installerPhoneCtrl.dispose();
    _customerNameCtrl.dispose();
    _customerEmailCtrl.dispose();
    _customerAddressCtrl.dispose();
    _customerPostcodeCtrl.dispose();
    _floorAreaCtrl.dispose();
    _electricalCertifierCtrl.dispose();
    _wherePurchasedCtrl.dispose();
    _invoiceNumberCtrl.dispose();
    _purchaseDateCtrl.dispose();
    _installDateCtrl.dispose();
    _scrollCtrl.dispose();
    _fnInstallerName.dispose();
    _fnCustomerName.dispose();
    _fnProductType.dispose();
    _fnCertifier.dispose();
    _fnWherePurchased.dispose();
    super.dispose();
  }

  Future<void> _prefillInstallerFromProfile() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (_installerNameCtrl.text.isEmpty) {
          _installerNameCtrl.text = (data['fullName'] ?? '').toString();
        }
        if (_installerCompanyCtrl.text.isEmpty) {
          _installerCompanyCtrl.text = (data['companyName'] ?? '').toString();
        }
        if (_installerPhoneCtrl.text.isEmpty) {
          _installerPhoneCtrl.text = (data['phoneNumber'] ?? '').toString();
        }
      }
    } catch (_) {}
  }

  bool get _isGuest => _auth.currentUser == null || _auth.currentUser!.isAnonymous;

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.animateTo(0,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      switch (step) {
        case 1:
          FocusScope.of(context).requestFocus(_fnInstallerName);
          break;
        case 2:
          FocusScope.of(context).requestFocus(_fnCustomerName);
          break;
        case 3:
          FocusScope.of(context).requestFocus(_fnProductType);
          break;
        case 4:
          FocusScope.of(context).requestFocus(_fnCertifier);
          break;
        case 5:
          FocusScope.of(context).requestFocus(_fnWherePurchased);
          break;
      }
    });
  }

  bool _validateStep(int step) {
    switch (step) {
      case 1:
        return _installerNameCtrl.text.trim().isNotEmpty &&
            _installerPhoneCtrl.text.trim().isNotEmpty;
      case 2:
        final email = _customerEmailCtrl.text.trim();
        final emailOk = email.contains('@') && email.contains('.');
        return _customerNameCtrl.text.trim().isNotEmpty &&
            emailOk &&
            _customerAddressCtrl.text.trim().isNotEmpty &&
            _customerPostcodeCtrl.text.trim().isNotEmpty;
      case 3:
        final needRooms = _productType == 'Underfloor Heating';
        return _productType.isNotEmpty &&
            _productDetails.isNotEmpty &&
            (!needRooms || (_selectedRooms.isNotEmpty && _floorAreaCtrl.text.trim().isNotEmpty));
      case 4:
        return _electricalCertifierCtrl.text.trim().isNotEmpty &&
            _rcdFitted.isNotEmpty;
      case 5:
        final datesOk = _purchaseDate.isNotEmpty && _installDate.isNotEmpty;
        return datesOk && _wherePurchasedCtrl.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _pickDate({required bool isPurchase}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 6),
      lastDate: DateTime(now.year + 1),
      initialDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _gold,
              surface: _dark,
              onSurface: _white,
              onPrimary: _white,
            ),
            dialogBackgroundColor: _dark,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final dd = picked.day.toString().padLeft(2, '0');
      final mm = picked.month.toString().padLeft(2, '0');
      final yyyy = picked.year.toString();
      final formatted = '$dd/$mm/$yyyy';
      setState(() {
        if (isPurchase) {
          _purchaseDate = formatted;
          _purchaseDateCtrl.text = formatted;
        } else {
          _installDate = formatted;
          _installDateCtrl.text = formatted;
        }
      });
    }
  }

  String _genWarrantyId() {
    final t = DateTime.now().millisecondsSinceEpoch;
    return 'W$t';
  }

  Future<void> _submitWarranty() async {
    if (!_validateStep(5)) {
      setState(() => _showValidationErrors = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a warranty.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final id = _genWarrantyId();
      final data = {
        'id': id,
        'userId': user.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,

        // Installer
        'installerName': _installerNameCtrl.text.trim(),
        'installerCompany': _installerCompanyCtrl.text.trim(),
        'installerPhone': _installerPhoneCtrl.text.trim(),

        // Customer
        'customerName': _customerNameCtrl.text.trim(),
        'customerEmail': _customerEmailCtrl.text.trim(),
        'customerAddress': _customerAddressCtrl.text.trim(),
        'customerPostcode': _customerPostcodeCtrl.text.trim(),

        // Product
        'productType': _productType,
        'productDetails': _productDetails,
        'roomTypes': _selectedRooms.toList(),
        'floorArea': _floorAreaCtrl.text.trim(),

        // Electrical
        'electricalCertifier': _electricalCertifierCtrl.text.trim(),
        'rcdFitted': _rcdFitted,

        // Purchase
        'purchaseDate': _purchaseDate,
        'installationDate': _installDate,
        'wherePurchased': _wherePurchasedCtrl.text.trim(),
        'invoiceNumber': _invoiceNumberCtrl.text.trim(),

        // PDF placeholder
        'pdfUrl': null,
      };

      await _db.collection('warranties').doc(id).set(data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Warranty submitted!')),
      );

      _tabController.animateTo(1);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit warranty: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: _black,
        appBar: AppBar(
          backgroundColor: _black,
          title: Text('Register a Warranty', style: GoogleFonts.raleway(color: _white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: _white,
            labelColor: _white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'New Warranty'),
              Tab(text: 'Saved Warranties'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNewWarranty(),
            _SavedWarrantiesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewWarranty() {
    if (_isGuest) {
      return _guestView();
    }
    return Column(
      children: [
        _buildStepper(),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _buildStepContent(),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _guestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, size: 80, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              'Please log in to register and view your warranties.',
              style: GoogleFonts.raleway(color: _white, fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.login);
              },
              style: ElevatedButton.styleFrom(backgroundColor: _gold),
              child: Text('Login / Register', style: GoogleFonts.raleway(color: _black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final steps = const ['Installer', 'Customer', 'Product', 'Electrical', 'Purchase', 'Submit'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(steps.length, (i) {
          final stepNum = i + 1;
          final isDone = stepNum < _currentStep;
          final isCurrent = stepNum == _currentStep;
          final ballColor = (isDone || isCurrent) ? _gold : Colors.grey;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    _circle(ballColor, isDone ? Icons.check : null, stepNum.toString(), isDone),
                    if (i != steps.length - 1)
                      Expanded(
                        child: Container(height: 2, color: (stepNum < _currentStep) ? _gold : Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _circle(Color c, IconData? icon, String fallback, bool showIcon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: showIcon
          ? Icon(icon, size: 16, color: _white)
          : Text(fallback, style: GoogleFonts.raleway(color: _white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _stepInstaller();
      case 2:
        return _stepCustomer();
      case 3:
        return _stepProduct();
      case 4:
        return _stepElectrical();
      case 5:
        return _stepPurchase();
      case 6:
      default:
        return _stepConfirm();
    }
  }

  // -------- Helpers (no underline) --------

  InputDecoration _decNoBorder(String label, {String? errorText, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.raleway(color: _labelWhite),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorText: errorText,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    );
  }

  TextStyle get _fieldTextStyle => GoogleFonts.raleway(color: _white);

  // -------- Steps --------

  Widget _stepInstaller() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Installer Details',
            style: GoogleFonts.raleway(color: _white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        TextField(
          focusNode: _fnInstallerName,
          controller: _installerNameCtrl,
          style: _fieldTextStyle,
          decoration: _decNoBorder(
            'Installer Full Name',
            errorText: _showValidationErrors && _installerNameCtrl.text.trim().isEmpty ? 'Required' : null,
          ),
        ),
        const Divider(color: Colors.white24, height: 16),
        TextField(
          controller: _installerCompanyCtrl,
          style: _fieldTextStyle,
          decoration: _decNoBorder('Company Name (Optional)'),
        ),
        const Divider(color: Colors.white24, height: 16),
        TextField(
          controller: _installerPhoneCtrl,
          style: _fieldTextStyle,
          keyboardType: TextInputType.phone,
          decoration: _decNoBorder(
            'Phone Number',
            errorText: _showValidationErrors && _installerPhoneCtrl.text.trim().isEmpty ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  Widget _stepCustomer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Customer & Address Details',
            style: GoogleFonts.raleway(color: _white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        TextField(
          focusNode: _fnCustomerName,
          controller: _customerNameCtrl,
          style: _fieldTextStyle,
          decoration: _decNoBorder(
            'Customer Full Name',
            errorText: _showValidationErrors && _customerNameCtrl.text.trim().isEmpty ? 'Required' : null,
          ),
        ),
        const Divider(color: Colors.white24, height: 16),
        TextField(
          controller: _customerEmailCtrl,
          style: _fieldTextStyle,
          keyboardType: TextInputType.emailAddress,
          decoration: _decNoBorder(
            'Customer Email',
            errorText: _showValidationErrors &&
                    (_customerEmailCtrl.text.trim().isEmpty ||
                        !_customerEmailCtrl.text.contains('@') ||
                        !_customerEmailCtrl.text.contains('.'))
                ? 'Enter a valid email'
                : null,
          ),
        ),
        const Divider(color: Colors.white24, height: 16),
        TextField(
          controller: _customerAddressCtrl,
          style: _fieldTextStyle,
          decoration: _decNoBorder(
            'Customer Address',
            errorText: _showValidationErrors && _customerAddressCtrl.text.trim().isEmpty ? 'Required' : null,
          ),
        ),
        const Divider(color: Colors.white24, height: 16),
        TextField(
          controller: _customerPostcodeCtrl,
          style: _fieldTextStyle,
          decoration: _decNoBorder(
            'Customer Postcode',
            errorText: _showValidationErrors && _customerPostcodeCtrl.text.trim().isEmpty ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  Widget _stepProduct() {
    final productTypes = const ['Underfloor Heating', 'Frost Protection'];

    final detailsMap = {
      'Underfloor Heating': [
        'PKM-065 heating mats',
        'PKM-110 heating mats',
        'PKM-160 heating mats',
        'PKM-200 heating mats',
        'PKM-240 heating mats',
        'CBM-150 underlaminate foil mat',
        'HMHMAT160W heating mat',
        'PKC-3.0 3mm cable',
        'PKC-5.0 5mm in-screed cable',
        'HMHCAB3.5 3.5mm cable',
      ],
      'Frost Protection': [
        'Trace Heating',
        'PipeGuard frost protection',
        'Gutter heating',
        'Driveway, Ramp and Walkway heating',
        'Vineyard frost protection',
        'Roof heating',
      ],
    };
    final detailOptions = detailsMap[_productType] ?? const <String>[];

    InputDecoration _dropDec(String label, {String? errorText}) => InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.raleway(color: _labelWhite),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorText: errorText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Product Details',
            style: GoogleFonts.raleway(color: _white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        // Product Type
        DropdownButtonFormField<String>(
          focusNode: _fnProductType,
          value: _productType.isEmpty ? null : _productType,
          items: productTypes
              .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t, style: GoogleFonts.raleway(color: _white)),
                  ))
              .toList(),
          onChanged: (v) {
            setState(() {
              _productType = v ?? '';
              _productDetails = '';
              _selectedRooms.clear();
              _floorAreaCtrl.clear();
            });
          },
          dropdownColor: _cardGrey,
          iconEnabledColor: _white,
          style: GoogleFonts.raleway(color: _white),
          decoration: _dropDec('Product Type', errorText: _showValidationErrors && _productType.isEmpty ? 'Required' : null),
        ),
        const Divider(color: Colors.white24, height: 16),

        // Product Details
        DropdownButtonFormField<String>(
          value: _productDetails.isEmpty ? null : _productDetails,
          items: detailOptions
              .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t, style: GoogleFonts.raleway(color: _white)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _productDetails = v ?? ''),
          dropdownColor: _cardGrey,
          iconEnabledColor: _white,
          style: GoogleFonts.raleway(color: _white),
          decoration: _dropDec('Product Details', errorText: _showValidationErrors && _productDetails.isEmpty ? 'Required' : null),
        ),

        if (_productType == 'Underfloor Heating' && _productDetails.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Type of room(s):', style: GoogleFonts.raleway(color: _white.withOpacity(0.9))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: -8,
            children: _roomOptions.map((room) {
              final selected = _selectedRooms.contains(room);
              return FilterChip(
                selected: selected,
                onSelected: (s) {
                  setState(() {
                    if (s) {
                      _selectedRooms.add(room);
                    } else {
                      _selectedRooms.remove(room);
                    }
                  });
                },
                label: Text(room, style: GoogleFonts.raleway(color: _white)),
                selectedColor: _gold.withOpacity(0.2),
                checkmarkColor: _white,
                backgroundColor: _cardGrey,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _floorAreaCtrl,
            style: _fieldTextStyle,
            keyboardType: TextInputType.number,
            decoration: _decNoBorder(
              'Approx. floor area covered (e.g., 15m²)',
              errorText: _showValidationErrors &&
                      (_productType == 'Underfloor Heating') &&
                      (_selectedRooms.isEmpty || _floorAreaCtrl.text.trim().isEmpty)
                  ? 'Required for UFH'
                  : null,
            ),
          ),
          const Divider(color: Colors.white24, height: 16),
        ],
      ],
    );
  }

  Widget _stepElectrical() {
    InputDecoration _dropDec(String label, {String? errorText}) => InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.raleway(color: _labelWhite),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorText: errorText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4: Electrical Details',
            style: GoogleFonts.raleway(color: _white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        TextField(
          focusNode: _fnCertifier,
          controller: _electricalCertifierCtrl,
          style: _fieldTextStyle,
          decoration: _decNoBorder(
            'Name/Company who issued Part P / Minor Works Certificate',
            errorText: _showValidationErrors && _electricalCertifierCtrl.text.trim().isEmpty
                ? 'Required'
                : null,
          ),
        ),
        const Divider(color: Colors.white24, height: 16),

        // RCD fitted (Yes/No)
        DropdownButtonFormField<String>(
          value: _rcdFitted.isEmpty ? null : _rcdFitted,
          items: const [
            DropdownMenuItem(value: 'Yes', child: Text('Yes', style: TextStyle(color: _white))),
            DropdownMenuItem(value: 'No', child: Text('No', style: TextStyle(color: _white))),
          ],
          onChanged: (v) => setState(() => _rcdFitted = v ?? ''),
          dropdownColor: _cardGrey,
          iconEnabledColor: _white,
          style: GoogleFonts.raleway(color: _white),
          decoration: _dropDec('Has an RCD been fitted?', errorText: _showValidationErrors && _rcdFitted.isEmpty ? 'Required' : null),
        ),
      ],
    );
  }

  Widget _stepPurchase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 5: Purchase Details',
            style: GoogleFonts.raleway(color: _white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        TextField(
          focusNode: _fnWherePurchased,
          controller: _wherePurchasedCtrl,
          style: _fieldTextStyle,
          decoration: _decNoBorder(
            'Where Purchased?',
            errorText: _showValidationErrors && _wherePurchasedCtrl.text.trim().isEmpty
                ? 'Required'
                : null,
          ),
        ),
        const Divider(color: Colors.white24, height: 16),

        // Purchase Date (readOnly)
        TextField(
          controller: _purchaseDateCtrl,
          readOnly: true,
          onTap: () => _pickDate(isPurchase: true),
          style: _fieldTextStyle,
          decoration: _decNoBorder(
            'Date of Purchase',
            errorText: _showValidationErrors && _purchaseDateCtrl.text.trim().isEmpty ? 'Required' : null,
            suffixIcon: const Icon(Icons.calendar_today, color: _white),
          ),
        ),
        const Divider(color: Colors.white24, height: 16),

        // Install Date (readOnly)
        TextField(
          controller: _installDateCtrl,
          readOnly: true,
          onTap: () => _pickDate(isPurchase: false),
          style: _fieldTextStyle,
          decoration: _decNoBorder(
            'Date of Installation',
            errorText: _showValidationErrors && _installDateCtrl.text.trim().isEmpty ? 'Required' : null,
            suffixIcon: const Icon(Icons.build, color: _white),
          ),
        ),
        const Divider(color: Colors.white24, height: 16),

        TextField(
          controller: _invoiceNumberCtrl,
          style: _fieldTextStyle,
          decoration: _decNoBorder('Invoice/Receipt/Order Number (Optional)'),
        ),
      ],
    );
  }

  Widget _stepConfirm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 6: Confirm Details',
            style: GoogleFonts.raleway(color: _white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Please review all the information below before submitting your warranty.',
            style: GoogleFonts.raleway(color: Colors.white70)),

        const SizedBox(height: 16),
        _summarySection('Installer Details', {
          'Installer Name': _installerNameCtrl.text,
          'Company': _installerCompanyCtrl.text,
          'Phone': _installerPhoneCtrl.text,
        }),

        _summarySection('Customer Details', {
          'Customer Name': _customerNameCtrl.text,
          'Email': _customerEmailCtrl.text,
          'Address': _customerAddressCtrl.text,
          'Postcode': _customerPostcodeCtrl.text,
        }),

        _summarySection('Product Details', {
          'Product Type': _productType,
          'Details': _productDetails,
        }),

        if (_productType == 'Underfloor Heating')
          _summarySection('Installation Details', {
            'Room(s)': _selectedRooms.join(', '),
            'Floor Area': _floorAreaCtrl.text,
          }),

        _summarySection('Electrical Details', {
          'Certified By': _electricalCertifierCtrl.text,
          'RCD Fitted': _rcdFitted,
        }),

        _summarySection('Purchase Details', {
          'Purchase Date': _purchaseDate,
          'Install Date': _installDate,
          'Purchased From': _wherePurchasedCtrl.text,
          'Invoice #': _invoiceNumberCtrl.text,
        }),
      ],
    );
  }

  Widget _summarySection(String title, Map<String, String> entries) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.raleway(
                  color: _gold, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...entries.entries.map((e) => _summaryRow(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    final empty = value.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$label: ',
              style: GoogleFonts.raleway(
                  color: empty ? _gold : _white, fontWeight: FontWeight.w600)),
          if (empty) ...[
            const Icon(Icons.warning, color: _gold, size: 16),
            Text(' Missing', style: GoogleFonts.raleway(color: _gold)),
          ] else
            Expanded(child: Text(value, style: GoogleFonts.raleway(color: _white))),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final totalSteps = 6;
    final isLast = _currentStep == totalSteps;
    return Container(
      color: _dark,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          if (_currentStep > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _goToStep(_currentStep - 1),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _white),
                  foregroundColor: _white,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Previous'),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 12),
          Expanded(
            child: isLast
                ? ElevatedButton(
                    onPressed: _submitting ? null : _submitWarranty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: _white),
                          )
                        : Text('Submit Warranty',
                            style: GoogleFonts.raleway(color: _white)),
                  )
                : ElevatedButton(
                    onPressed: () {
                      final ok = _validateStep(_currentStep);
                      if (ok) {
                        setState(() => _showValidationErrors = false);
                        _goToStep(_currentStep + 1);
                      } else {
                        setState(() => _showValidationErrors = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please complete all required fields.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Next', style: TextStyle(color: _white)),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Saved warranties tab
class _SavedWarrantiesList extends StatelessWidget {
  _SavedWarrantiesList();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspace_premium, size: 80, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                'Please log in to view your saved warranties.',
                style: GoogleFonts.raleway(color: _white, fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, Routes.login),
                style: ElevatedButton.styleFrom(backgroundColor: _gold),
                child: Text('Login / Register', style: GoogleFonts.raleway(color: _black)),
              ),
            ],
          ),
        ),
      );
    }

    final q = _db
        .collection('warranties')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .limit(100);

    return StreamBuilder<QuerySnapshot>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _white));
        }
        if (snap.hasError) {
          return Center(
            child: Text(snap.error.toString(),
                style: GoogleFonts.raleway(color: _white)),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text('No warranties found.',
                style: GoogleFonts.raleway(color: _white, fontSize: 16)),
          );
        }
        final items = docs
            .map((d) => WarrantyItem.fromMap(d.data() as Map<String, dynamic>))
            .toList();

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (_, i) => _card(context, items[i]),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: items.length,
        );
      },
    );
  }

  Widget _card(BuildContext context, WarrantyItem w) {
    return Card(
      color: _cardGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 110,
          child: Stack(
            children: [
              Positioned(
                left: 0, right: 0, top: 0,
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: _white),
                    const SizedBox(width: 8),
                    Text(w.id,
                        style: GoogleFonts.raleway(
                            color: _white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer: ${w.customerName}',
                        style: GoogleFonts.raleway(color: _white)),
                    Text('Date: ${w.installationDate}',
                        style: GoogleFonts.raleway(color: _white)),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: w.pdfUrl == null
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: _white),
                      )
                    : const Icon(Icons.check_circle, color: Color(0xFF81C784), size: 24),
              ),
              if (w.pdfUrl != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (w.pdfUrl != null) {
                            Share.share('View my warranty certificate: ${w.pdfUrl}');
                          }
                        },
                        icon: const Icon(Icons.share, color: _white),
                        tooltip: 'Share',
                      ),
                      IconButton(
                        onPressed: () async {
                          await _handleDownload(context, w);
                        },
                        icon: const Icon(Icons.download, color: _white),
                        tooltip: 'Save',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDownload(BuildContext context, WarrantyItem w) async {
    try {
      final resolved = await _resolvePdfUrl(w.pdfUrl);
      if (resolved == null) {
        _toast(context, 'PDF link not available yet');
        return;
      }

      // First try to open externally (browser/PDF viewer)…
      final canExternal = await _tryOpenExternal(resolved);
      if (canExternal) return;

      // …if that fails, download to temp and open.
      final filePath = await _downloadToTemp(resolved, fileName: '${w.id}.pdf');
      if (filePath == null) {
        _toast(context, 'Failed to download PDF');
        return;
      }
      await OpenFilex.open(filePath);
    } catch (e) {
      _toast(context, 'Could not open PDF: $e');
    }
  }

  Future<String?> _resolvePdfUrl(String? pdfUrl) async {
    if (pdfUrl == null || pdfUrl.isEmpty) return null;

    // If it's already an https URL, return as-is
    if (pdfUrl.startsWith('http://') || pdfUrl.startsWith('https://')) {
      return pdfUrl;
    }

    // If it's a gs:// URL or a storage path, resolve via Firebase Storage
    final storage = FirebaseStorage.instance;
    if (pdfUrl.startsWith('gs://')) {
      final ref = storage.refFromURL(pdfUrl);
      return ref.getDownloadURL();
    } else {
      // assume it's a path in your default bucket (e.g. "warranty_pdfs/W123.pdf")
      final ref = storage.ref(pdfUrl);
      return ref.getDownloadURL();
    }
  }

  Future<bool> _tryOpenExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      return ok;
    }
    return false;
    }

  Future<String?> _downloadToTemp(String url, {required String fileName}) async {
    try {
      final uri = Uri.parse(url);
      final resp = await http.get(uri);
      if (resp.statusCode != 200) return null;

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/$fileName';
      final f = await File(path).writeAsBytes(resp.bodyBytes, flush: true);
      return f.path;
    } catch (_) {
      return null;
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
