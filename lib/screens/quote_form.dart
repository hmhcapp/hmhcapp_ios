// lib/screens/quote_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/quote.dart';
import '../services/quote_service.dart';
import '../routes.dart';
import '../widgets/atmospheric_dark_background.dart';

const _quoteBackground = Colors.black;
const _quoteText = atmosphericPrimaryText;

class QuoteFormScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryRoute;
  final Color appBarColor;

  const QuoteFormScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryRoute,
    required this.appBarColor,
  });

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  final _picker = ImagePicker();

  String get _categoryDescription {
    if (widget.categoryTitle.contains('Underfloor')) {
      return 'Request a tailored underfloor heating quote.';
    }
    if (widget.categoryTitle.contains('Frost')) {
      return 'Request a frost protection project quote.';
    }
    if (widget.categoryTitle.contains('Mirror')) {
      return 'Request a quote for mirror demister products.';
    }
    return 'Tell us about another product or project.';
  }

  Color get _onAccent =>
      ThemeData.estimateBrightnessForColor(widget.appBarColor) ==
          Brightness.light
      ? const Color(0xFF17120D)
      : Colors.white;

  //==[CORRECTION START] Use TextEditingControllers for each TextField ==
  late final TextEditingController _distributorController;
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _emailController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _postcodeController;
  late final TextEditingController _projectNameController;
  late final TextEditingController _itemsNeededDateController;
  late final TextEditingController _additionalInfoController;
  //==[CORRECTION END]====================================================

  // Fields
  String projectStage = 'Planning & Design';
  final projectStages = const [
    'Planning & Design',
    'Ready to Order',
    'In Construction',
  ];

  XFile? pickedImage;

  bool submitting = false;
  String? warn;

  final _dateFmt = DateFormat('dd/MM/yyyy');

  //==[CORRECTION START] Initialize controllers in initState and dispose them ==
  @override
  void initState() {
    super.initState();
    _distributorController = TextEditingController();
    _nameController = TextEditingController();
    _companyController = TextEditingController();
    _emailController = TextEditingController();
    _telephoneController = TextEditingController();
    _postcodeController = TextEditingController();
    _projectNameController = TextEditingController();
    _itemsNeededDateController = TextEditingController();
    _additionalInfoController = TextEditingController();
  }

  @override
  void dispose() {
    _distributorController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _postcodeController.dispose();
    _projectNameController.dispose();
    _itemsNeededDateController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }
  //==[CORRECTION END]====================================================

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = now.add(const Duration(days: 365));

    DateTime initialDate = firstDate;
    if (_itemsNeededDateController.text.isNotEmpty) {
      try {
        final parsedDate = _dateFmt.parse(_itemsNeededDateController.text);
        if (parsedDate.isAfter(firstDate) && parsedDate.isBefore(lastDate)) {
          initialDate = parsedDate;
        }
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.appBarColor,
              onPrimary: _onAccent,
              surface: atmosphericSurface,
              onSurface: _quoteText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: widget.appBarColor),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: atmosphericSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      //==[CORRECTION] Update the controller's text
      setState(() => _itemsNeededDateController.text = _dateFmt.format(picked));
    }
  }

  Future<void> _pickGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x != null) setState(() => pickedImage = x);
  }

  Future<void> _pickCamera() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (x != null) setState(() => pickedImage = x);
  }

  Future<void> _call() async {
    final uri = Uri.parse('tel:01444247020');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showWarn('Unable to open phone dialler.');
    }
  }

  Future<void> _submit() async {
    //==[CORRECTION] Get values from controllers
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      _showWarn('Please enter your name and email.');
      return;
    }
    setState(() => submitting = true);

    final id = _generateId();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final quote = Quote(
      id: id,
      categoryTitle: widget.categoryTitle,
      distributor: _distributorController.text,
      name: name,
      company: _companyController.text,
      email: email,
      telephone: _telephoneController.text,
      postcode: _postcodeController.text,
      projectName: _projectNameController.text,
      projectStage: projectStage,
      itemsNeededDate: _itemsNeededDateController.text,
      additionalInfo: _additionalInfoController.text,
      imageUrl: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      userId: uid,
    );
    //==[CORRECTION END]====================================================

    File? imageFile;
    if (pickedImage != null) {
      imageFile = File(pickedImage!.path);
    }

    try {
      await QuoteService.instance.submitQuote(
        quote,
        imageFile: imageFile,
        userId: uid,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Submitted!'),
          action: SnackBarAction(
            label: 'View in Saved',
            onPressed: () {
              Navigator.popUntil(
                context,
                (r) =>
                    r.settings.name == Routes.getAQuoteCategorySelection ||
                    r.isFirst,
              );
              Navigator.pushNamed(
                context,
                Routes.getAQuoteCategorySelection,
                arguments: 1,
              );
            },
          ),
        ),
      );

      Navigator.popUntil(
        context,
        (r) =>
            r.settings.name == Routes.getAQuoteCategorySelection || r.isFirst,
      );
      Navigator.pushNamed(
        context,
        Routes.getAQuoteCategorySelection,
        arguments: 1,
      );
    } catch (e) {
      _showWarn('Submission failed. Please try again.');
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  void _showWarn(String m) {
    setState(() => warn = m);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => warn = null);
    });
  }

  String _generateId() {
    final now = DateTime.now();
    String pad2(int value) => value.toString().padLeft(2, '0');
    return '${now.year}${pad2(now.month)}${pad2(now.day)}-${now.millisecondsSinceEpoch % 100000}';
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.raleway(
      fontSize: 16,
      color: atmosphericPrimaryText,
    );

    return Scaffold(
      backgroundColor: _quoteBackground,
      appBar: AppBar(
        toolbarHeight: 78,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.categoryTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _categoryDescription,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.raleway(
                color: atmosphericSecondaryText,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF101111),
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 64,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: widget.appBarColor,
            size: 30,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.edit_note, color: widget.appBarColor),
          ),
        ],
      ),
      body: Theme(
        data: atmosphericDarkTheme(context, accent: widget.appBarColor),
        child: AtmosphericDarkBackground(
          accentColor: widget.appBarColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Card(
                color: atmosphericSurface,
                surfaceTintColor: Colors.transparent,
                elevation: 12,
                shadowColor: Colors.black.withValues(alpha: 0.65),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: widget.appBarColor.withValues(alpha: 0.32),
                  ),
                ),
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                  child: ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.appBarColor.withValues(alpha: 0.18),
                              widget.appBarColor.withValues(alpha: 0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: widget.appBarColor.withValues(alpha: 0.38),
                          ),
                        ),
                        child: Text(
                          'Complete the form below to get your quote or speak '
                          'to one of our experts.',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            height: 1.4,
                            color: _quoteText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: widget.appBarColor),
                          foregroundColor: widget.appBarColor,
                          backgroundColor: widget.appBarColor.withValues(
                            alpha: 0.08,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _call,
                        icon: const Icon(Icons.phone),
                        label: Text(
                          'Call us on 01444 247020',
                          style: GoogleFonts.raleway(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('Submit Your Plans'),
                      Text(
                        'For the most accurate quote, please provide your plans.',
                        style: GoogleFonts.raleway(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _uploadBtn(
                              'Take Photo',
                              Icons.photo_camera,
                              _pickCamera,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _uploadBtn(
                              'Upload Plan',
                              Icons.image,
                              _pickGallery,
                            ),
                          ),
                        ],
                      ),
                      if (pickedImage != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(pickedImage!.path),
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _sectionTitle('Your Details'),
                      //==[CORRECTION] Pass controllers to the widget methods
                      _tf(
                        'Your Heat Mat distributor/wholesaler',
                        _distributorController,
                        textStyle,
                      ),
                      _tf('Name*', _nameController, textStyle),
                      _tf('Your company name', _companyController, textStyle),
                      _tf(
                        'Email address*',
                        _emailController,
                        textStyle,
                        keyboard: TextInputType.emailAddress,
                      ),
                      _tf(
                        'Phone number',
                        _telephoneController,
                        textStyle,
                        keyboard: TextInputType.phone,
                      ),
                      _tf('Postcode', _postcodeController, textStyle),
                      const SizedBox(height: 16),
                      _sectionTitle('Project Details'),
                      _tf(
                        'Project Name (if applicable)',
                        _projectNameController,
                        textStyle,
                      ),
                      //==[CORRECTION END]====================================================
                      _dropdown(
                        'What stage is the project at?',
                        projectStages,
                        projectStage,
                        (v) => setState(() => projectStage = v),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: TextField(
                            //==[CORRECTION] Use the dedicated date controller
                            controller: _itemsNeededDateController,
                            //==[CORRECTION END]================================
                            readOnly: true,
                            style: GoogleFonts.raleway(
                              fontSize: 16,
                              color: _quoteText,
                            ),
                            decoration: InputDecoration(
                              labelText: 'When do you need the items?',
                              labelStyle: GoogleFonts.raleway(),
                              fillColor: atmosphericRaisedSurface,
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: widget.appBarColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: atmosphericBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: widget.appBarColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _sectionTitle('Additional Information'),
                      Text(
                        "Don't worry if you miss any details. Our team will contact you if we need more information.",
                        style: GoogleFonts.raleway(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      //==[CORRECTION] Pass controller to the multiline widget method
                      _multiline(
                        'Please supply any further information...',
                        _additionalInfoController,
                        textStyle,
                      ),
                      //==[CORRECTION END]====================================================
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: widget.appBarColor,
                            foregroundColor: _onAccent,
                            disabledBackgroundColor: widget.appBarColor
                                .withValues(alpha: 0.38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          onPressed: submitting ? null : _submit,
                          child: submitting
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _onAccent,
                                  ),
                                )
                              : Text(
                                  'SUBMIT REQUEST',
                                  style: GoogleFonts.raleway(
                                    fontWeight: FontWeight.bold,
                                    color: _onAccent,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (warn != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Center(child: _toast(warn!)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toast(String msg) => Card(
    color: Colors.black87,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber, color: Colors.white),
          const SizedBox(width: 12),
          Text(msg, style: GoogleFonts.raleway(color: Colors.white)),
        ],
      ),
    ),
  );

  Widget _uploadBtn(String text, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: widget.appBarColor),
        foregroundColor: widget.appBarColor,
        backgroundColor: widget.appBarColor.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(100),
      ),
      icon: Icon(icon, size: 28),
      label: Text(text, style: GoogleFonts.raleway()),
    );
  }

  Widget _sectionTitle(String s) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 8),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: widget.appBarColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          s,
          style: GoogleFonts.raleway(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: _quoteText,
          ),
        ),
      ],
    ),
  );

  //==[CORRECTION START] Modify _tf and _multiline to accept controllers ==
  Widget _tf(
    String label,
    TextEditingController controller,
    TextStyle style, {
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: controller, // Use the controller
        // onChanged is no longer needed here
        keyboardType: keyboard,
        style: style,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.raleway(),
          fillColor: atmosphericRaisedSurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: atmosphericBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.appBarColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _multiline(
    String label,
    TextEditingController controller,
    TextStyle style,
  ) {
    return TextField(
      controller: controller, // Use the controller
      // onChanged is no longer needed here
      maxLines: 5,
      style: style,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.raleway(),
        fillColor: atmosphericRaisedSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: atmosphericBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.appBarColor, width: 2),
        ),
      ),
    );
  }
  //==[CORRECTION END]====================================================

  Widget _dropdown(
    String label,
    List<String> options,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          fillColor: atmosphericRaisedSurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: atmosphericBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.appBarColor, width: 2),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected,
            dropdownColor: atmosphericRaisedSurface,
            style: GoogleFonts.raleway(color: atmosphericPrimaryText),
            isExpanded: true,
            items: options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) {
              if (v != null) onSelected(v);
            },
          ),
        ),
      ),
    );
  }
}
