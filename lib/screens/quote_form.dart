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
  final projectStages = const ['Planning & Design', 'Ready to Order', 'In Construction'];

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
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.appBarColor,
              onPrimary: ThemeData.estimateBrightnessForColor(widget.appBarColor) == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              surface: const Color(0xFF3a3a3a),
              onSurface: Colors.white70,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: widget.appBarColor,
              ),
            ),
            dialogBackgroundColor: const Color(0xFF3a3a3a),
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
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => pickedImage = x);
  }

  Future<void> _pickCamera() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
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
      await QuoteService.instance.submitQuote(quote, imageFile: imageFile, userId: uid);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Submitted!'),
          action: SnackBarAction(
            label: 'View in Saved',
            onPressed: () {
              Navigator.popUntil(context, (r) => r.settings.name == Routes.getAQuoteCategorySelection || r.isFirst);
              Navigator.pushNamed(context, Routes.getAQuoteCategorySelection, arguments: 1);
            },
          ),
        ),
      );

      Navigator.popUntil(context, (r) => r.settings.name == Routes.getAQuoteCategorySelection || r.isFirst);
      Navigator.pushNamed(context, Routes.getAQuoteCategorySelection, arguments: 1);
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
    final pad2 = (int v) => v.toString().padLeft(2, '0');
    return '${now.year}${pad2(now.month)}${pad2(now.day)}-${now.millisecondsSinceEpoch % 100000}';
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.raleway(fontSize: 16);

    return Scaffold(
      backgroundColor: widget.appBarColor,
      appBar: AppBar(
        title: Text(widget.categoryTitle, style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.w400)),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        actions: const [Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.edit_note, color: Colors.white))],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            margin: const EdgeInsets.only(top: 8),
            child: ListView(
              children: [
                Text(
                  'Complete the form below to get your quote or speak to one of our experts.',
                  style: GoogleFonts.raleway(fontSize: 18, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: widget.appBarColor),
                    foregroundColor: widget.appBarColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _call,
                  icon: const Icon(Icons.phone),
                  label: Text('Call us on 01444 247020', style: GoogleFonts.raleway(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                _sectionTitle('Submit Your Plans'),
                Text('For the most accurate quote, please provide your plans.', style: GoogleFonts.raleway(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _uploadBtn('Take Photo', Icons.photo_camera, _pickCamera)),
                  const SizedBox(width: 16),
                  Expanded(child: _uploadBtn('Upload Plan', Icons.image, _pickGallery)),
                ]),
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
                _tf('Your Heat Mat distributor/wholesaler', _distributorController, textStyle),
                _tf('Name*', _nameController, textStyle),
                _tf('Your company name', _companyController, textStyle),
                _tf('Email address*', _emailController, textStyle, keyboard: TextInputType.emailAddress),
                _tf('Phone number', _telephoneController, textStyle, keyboard: TextInputType.phone),
                _tf('Postcode', _postcodeController, textStyle),
                const SizedBox(height: 16),
                _sectionTitle('Project Details'),
                _tf('Project Name (if applicable)', _projectNameController, textStyle),
                //==[CORRECTION END]====================================================
                _dropdown('What stage is the project at?', projectStages, projectStage, (v) => setState(() => projectStage = v)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextField(
                      //==[CORRECTION] Use the dedicated date controller
                      controller: _itemsNeededDateController,
                      //==[CORRECTION END]================================
                      readOnly: true,
                      style: GoogleFonts.raleway(fontSize: 16, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'When do you need the items?',
                        labelStyle: GoogleFonts.raleway(),
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionTitle('Additional Information'),
                Text(
                  "Don't worry if you miss any details. Our team will contact you if we need more information.",
                  style: GoogleFonts.raleway(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                //==[CORRECTION] Pass controller to the multiline widget method
                _multiline('Please supply any further information...', _additionalInfoController, textStyle),
                //==[CORRECTION END]====================================================
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: widget.appBarColor),
                    onPressed: submitting ? null : _submit,
                    child: submitting
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('SUBMIT REQUEST', style: GoogleFonts.raleway(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (warn != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _toast(warn!),
            ),
        ],
      ),
    );
  }

  Widget _toast(String msg) => Card(
        color: Colors.black87,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Text(msg, style: GoogleFonts.raleway(color: Colors.white)),
          ]),
        ),
      );

  Widget _uploadBtn(String text, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: widget.appBarColor),
        foregroundColor: widget.appBarColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size.fromHeight(100),
      ),
      icon: Icon(icon, size: 28),
      label: Text(text, style: GoogleFonts.raleway()),
    );
  }

  Widget _sectionTitle(String s) => Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 4),
        child: Text(s, style: GoogleFonts.raleway(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
      );

  //==[CORRECTION START] Modify _tf and _multiline to accept controllers ==
  Widget _tf(String label, TextEditingController controller, TextStyle style, {TextInputType? keyboard}) {
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
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _multiline(String label, TextEditingController controller, TextStyle style) {
    return TextField(
      controller: controller, // Use the controller
      // onChanged is no longer needed here
      maxLines: 5,
      style: style,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.raleway(),
        border: const OutlineInputBorder(),
      ),
    );
  }
  //==[CORRECTION END]====================================================


  Widget _dropdown(String label, List<String> options, String selected, ValueChanged<String> onSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected,
            isExpanded: true,
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) { if (v != null) onSelected(v); },
          ),
        ),
      ),
    );
  }
}