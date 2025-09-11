// lib/screens/get_a_quote.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../routes.dart';
import 'package:hmhcapp_ios/models/quote.dart';
import 'package:hmhcapp_ios/services/quote_service.dart';

class QuoteScreen extends StatelessWidget {
  final int initialTabIndex;
  const QuoteScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Get a Quote', style: GoogleFonts.raleway(color: Colors.white)),
          backgroundColor: const Color(0xFF333333),
          leading: const BackButton(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'New Quote'), Tab(text: 'Saved Quotes')],
          ),
        ),
        body: const TabBarView(
          children: [
            QuoteCategorySelectionScreen(),
            SavedQuotesScreen(),
          ],
        ),
      ),
    );
  }
}

class QuoteCategorySelectionScreen extends StatelessWidget {
  const QuoteCategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Colors.white.withOpacity(0.4), const Color(0xFF333333).withOpacity(0.6)],
    );

    final items = [
      _QuoteCat('Underfloor Heating', Icons.thermostat, const Color(0xFFF8B637), Routes.underfloorHeatingQuote),
      _QuoteCat('Frost Protection', Icons.ac_unit, const Color(0xFF009ADC), Routes.frostProtectionQuote),
      _QuoteCat('Mirror Demisters', Icons.filter_b_and_w, const Color(0xFF8BC34A), Routes.mirrorDemisterQuote),
      _QuoteCat('Other Products', Icons.category, const Color(0xFFE88A2B), Routes.otherProductsQuote),
    ];

    return Stack(
      children: [
        Positioned.fill(child: Image.asset('assets/images/diagonalpatternbg.jpg', fit: BoxFit.cover)),
        Positioned.fill(child: Container(decoration: BoxDecoration(gradient: gradient))),
        GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1,
          ),
          itemBuilder: (_, i) => _QuoteTile(item: items[i]),
        ),
      ],
    );
  }
}

class _QuoteCat {
  final String title; final IconData icon; final Color color; final String route;
  _QuoteCat(this.title, this.icon, this.color, this.route);
}

class _QuoteTile extends StatelessWidget {
  final _QuoteCat item;
  const _QuoteTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, item.route),
      style: ElevatedButton.styleFrom(
        backgroundColor: item.color, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 56, color: Colors.white.withOpacity(0.9)),
          const SizedBox(height: 12),
          Text(item.title.toUpperCase(), textAlign: TextAlign.center, style: GoogleFonts.raleway(fontWeight: FontWeight.w400)),
        ],
      ),
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
        setState(() { _loading = false; });
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
      return const Center(child: CircularProgressIndicator());
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
                style: GoogleFonts.raleway(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.login),
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
          child: Text(_error!, textAlign: TextAlign.center, style: GoogleFonts.raleway(fontSize: 16, color: Colors.black87)),
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
            style: GoogleFonts.raleway(fontSize: 16, color: Colors.black87),
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
    if (t.contains('Underfloor')) return const Color(0xFFF8B637);
    if (t.contains('Frost')) return const Color(0xFF009ADC);
    if (t.contains('Mirror')) return const Color(0xFF8BC34A);
    if (t.contains('Other')) return const Color(0xFFE88A2B);
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
      onTap: () => Navigator.pushNamed(context, Routes.quoteDetail, arguments: quote.id),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        color: Colors.white.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Stack(
            children: [
              Positioned(top: 0, right: 0, child: Icon(_catIcon(quote.categoryTitle), size: 28, color: color)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quote.categoryTitle, style: GoogleFonts.raleway(fontWeight: FontWeight.w400, fontSize: 18, color: color)),
                  const SizedBox(height: 4),
                  Text('Quote Ref: ${quote.id}', style: GoogleFonts.raleway(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  if (quote.projectName.isNotEmpty) _detailRow(Icons.assignment, quote.projectName),
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
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.raleway(fontSize: 14, color: Colors.black87))),
      ]),
    );
  }
}
