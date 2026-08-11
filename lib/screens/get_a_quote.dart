// lib/screens/get_a_quote.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../routes.dart';
import 'package:hmhcapp_ios/models/quote.dart';
import 'package:hmhcapp_ios/services/quote_service.dart';
import 'package:hmhcapp_ios/widgets/accent_navigation_card.dart';
import 'package:hmhcapp_ios/widgets/atmospheric_dark_background.dart';

const _quoteBackground = Colors.black;
const _quoteAccent = Color(0xFFE9882A);
const _quoteText = atmosphericPrimaryText;
const _quoteDivider = atmosphericBorder;

class QuoteScreen extends StatelessWidget {
  final int initialTabIndex;
  const QuoteScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: _quoteBackground,
        appBar: AppBar(
          toolbarHeight: 78,
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get a Quote',
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
                'Create and manage your project quotes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.raleway(
                  color: const Color(0xFFB7B7B7),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF101111),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: 64,
          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFEFA528),
              size: 30,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: _quoteAccent,
            tabs: [
              Tab(text: 'New Quote'),
              Tab(text: 'Saved Quotes'),
            ],
          ),
        ),
        body: const AtmosphericDarkBackground(
          accentColor: _quoteAccent,
          child: TabBarView(
            children: [QuoteCategorySelectionScreen(), SavedQuotesScreen()],
          ),
        ),
      ),
    );
  }
}

class QuoteCategorySelectionScreen extends StatelessWidget {
  const QuoteCategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _QuoteCat(
        'Underfloor Heating',
        'Request a tailored underfloor heating quote.',
        Icons.thermostat,
        Color(0xFFF4BE25),
        Routes.underfloorHeatingQuote,
      ),
      _QuoteCat(
        'Frost Protection',
        'Request a frost protection project quote.',
        Icons.ac_unit,
        Color(0xFF009ADC),
        Routes.frostProtectionQuote,
      ),
      _QuoteCat(
        'Mirror Demisters',
        'Request a quote for mirror demister products.',
        Icons.filter_b_and_w,
        Color(0xFF8BC34A),
        Routes.mirrorDemisterQuote,
      ),
      _QuoteCat(
        'Other Products',
        'Tell us about another product or project.',
        Icons.category,
        Color(0xFFE26A2D),
        Routes.otherProductsQuote,
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 174,
      ),
      itemBuilder: (_, i) => _QuoteTile(item: items[i]),
    );
  }
}

class _QuoteCat {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  const _QuoteCat(
    this.title,
    this.description,
    this.icon,
    this.color,
    this.route,
  );
}

class _QuoteTile extends StatelessWidget {
  final _QuoteCat item;
  const _QuoteTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return AccentNavigationCard(
      title: item.title,
      description: item.description,
      icon: item.icon,
      accentColor: item.color,
      onTap: () => Navigator.pushNamed(context, item.route),
    );
  }
}

class SavedQuotesScreen extends StatefulWidget {
  const SavedQuotesScreen({super.key});
  @override
  State<SavedQuotesScreen> createState() => _SavedQuotesScreenState();
}

class _SavedQuotesScreenState extends State<SavedQuotesScreen> with RouteAware {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.isAnonymous) {
        // Not logged in → no fetch. Just render the login prompt.
        setState(() {
          _loading = false;
        });
        return;
      }
      await QuoteService.instance.refresh(userUid: user.uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _quoteAccent),
      );
    }

    if (user == null || user.isAnonymous) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Login to view your saved quotes.',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  color: atmosphericPrimaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _quoteAccent,
                  foregroundColor: Colors.white,
                ),
                child: Text('Login / Register', style: GoogleFonts.raleway()),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              fontSize: 16,
              color: atmosphericPrimaryText,
            ),
          ),
        ),
      );
    }

    final quotes = QuoteService.instance.getQuotes();
    if (quotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'You have no saved quotes yet.\nSubmit a new quote request and it will appear here.',
            style: GoogleFonts.raleway(
              fontSize: 16,
              color: atmosphericPrimaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: quotes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _QuoteCard(quote: quotes[i]),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final Quote quote;
  const _QuoteCard({required this.quote});

  Color _catColor(String t) {
    if (t.contains('Underfloor')) return const Color(0xFFF4BE25);
    if (t.contains('Frost')) return const Color(0xFF009ADC);
    if (t.contains('Mirror')) return const Color(0xFF8BC34A);
    if (t.contains('Other')) return const Color(0xFFE26A2D);
    return Colors.grey;
  }

  IconData _catIcon(String t) {
    if (t.contains('Underfloor')) return Icons.thermostat;
    if (t.contains('Frost')) return Icons.ac_unit;
    if (t.contains('Mirror')) return Icons.filter_b_and_w;
    return Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final color = _catColor(quote.categoryTitle);
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, Routes.quoteDetail, arguments: quote.id),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _quoteDivider),
        ),
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        color: atmosphericSurface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  _catIcon(quote.categoryTitle),
                  size: 28,
                  color: color,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quote.categoryTitle,
                    style: GoogleFonts.raleway(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quote Ref: ${quote.id}',
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (quote.projectName.isNotEmpty)
                    _detailRow(Icons.assignment, quote.projectName),
                  _detailRow(
                    Icons.calendar_today,
                    'Submitted on ${DateTime.fromMillisecondsSinceEpoch(quote.timestamp).toLocal().toString().split(' ').first}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: atmosphericSecondaryText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.raleway(fontSize: 14, color: _quoteText),
            ),
          ),
        ],
      ),
    );
  }
}
