// lib/screens/quote_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  // Fields
  String distributor = '';
  String name = '';
  String company = '';
  String email = '';
  String telephone = '';
  String postcode = '';
  String projectName = '';
  String projectStage = 'Planning & Design';
  final projectStages = const ['Planning & Design', 'Ready to Order', 'In Construction'];
  String itemsNeededDate = '';
  String additionalInfo = '';

  XFile? pickedImage;

  bool submitting = false;
  String? warn;

  // ---- Date formatting & pickers ----
  final _dateFmt = DateFormat('dd/MM/yyyy');

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final last = now.add(const Duration(days: 365));

    if (Platform.isIOS) {
      DateTime temp = itemsNeededDate.isNotEmpty
          ? _dateFmt.parse(itemsNeededDate)
          : first;

      await showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return Container(
            height: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
            ),
            child: Column(
              children: [
                // Handle line and actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: GoogleFonts.raleway(color: Colors.black54)),
                      ),
                      Text('Select Date', style: GoogleFonts.raleway(fontWeight: FontWeight.w600)),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() => itemsNeededDate = _dateFmt.format(temp));
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Done',
                          style: GoogleFonts.raleway(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    minimumDate: first,
                    maximumDate: last,
                    initialDateTime: temp.isBefore(first)
                        ? first
                        : (temp.isAfter(last) ? last : temp),
                    onDateTimeChanged: (d) => temp = d,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: first,
        firstDate: first,
        lastDate: last,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        setState(() => itemsNeededDate = _dateFmt.format(picked));
      }
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
    if (name.trim().isEmpty || email.trim().isEmpty) {
      _showWarn('Please enter your name and email.');
      return;
    }
    setState(() => submitting = true);

    final id = _generateId();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final quote = Quote(
      id: id,
      categoryTitle: widget.categoryTitle,
      distributor: distributor,
      name: name,
      company: company,
      email: email,
      telephone: telephone,
      postcode: postcode,
      projectName: projectName,
      projectStage: projectStage,
      itemsNeededDate: itemsNeededDate,
      additionalInfo: additionalInfo,
      imageUrl: null, // storage path will be set by service if imageFile present
      timestamp: DateTime.now().millisecondsSinceEpoch,
      userId: uid,
    );

    // Convert XFile -> File if present
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

      // Also navigate to Saved tab
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
                _tf('Your Heat Mat distributor/wholesaler', (v) => distributor = v, textStyle),
                _tf('Name*', (v) => name = v, textStyle),
                _tf('Your company name', (v) => company = v, textStyle),
                _tf('Email address*', (v) => email = v, textStyle, keyboard: TextInputType.emailAddress),
                _tf('Phone number', (v) => telephone = v, textStyle, keyboard: TextInputType.phone),
                _tf('Postcode', (v) => postcode = v, textStyle),

                const SizedBox(height: 16),
                _sectionTitle('Project Details'),
                _tf('Project Name (if applicable)', (v) => projectName = v, textStyle),
                _dropdown('What stage is the project at?', projectStages, projectStage, (v) => setState(() => projectStage = v)),

                // --- Fancy date field ---
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(text: itemsNeededDate)
                        ..selection = TextSelection.collapsed(offset: itemsNeededDate.length),
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
                _multiline('Please supply any further information...', (v) => additionalInfo = v, textStyle),

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

  Widget _tf(String label, ValueChanged<String> onChanged, TextStyle style, {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        onChanged: onChanged,
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

  Widget _multiline(String label, ValueChanged<String> onChanged, TextStyle style) {
    return TextField(
      onChanged: onChanged,
      maxLines: 5,
      style: style,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.raleway(),
        border: const OutlineInputBorder(),
      ),
    );
  }

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
