import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import only what's needed to avoid name clashes
import 'screens/product_category_selection.dart' show ProductCategorySelectionScreen;
import 'screens/product_factsheets.dart'
    show ProductFactsheetsScreen, CategoryData, underfloorHeatingFactsheets, frostProtectionFactsheets;

class Routes {
  static const home = '/';
  static const productCategorySelection = '/product_category_selection';
  static const underfloorHeatingFactsheetsRoute = '/underfloor_heating_factsheets';
  static const frostProtectionFactsheetsRoute = '/frost_protection_factsheets';
  static const productInstructionCategorySelection = '/product_instruction_category_selection';
  static const caseStudies = '/case_studies';
  static const getAQuoteCategorySelection = '/get_a_quote_category_selection';
  static const registerWarranty = '/register_warranty';
  static const installerTools = '/installer_tools';
  static const profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case productCategorySelection:
        return MaterialPageRoute(builder: (_) => const ProductCategorySelectionScreen());

      case underfloorHeatingFactsheetsRoute:
        return MaterialPageRoute(
          builder: (_) => ProductFactsheetsScreen(
            categoryTitle: 'Underfloor Heating Factsheets',
            appBarColor: const Color(0xFFDD4F2E),
            factsheetData: underfloorHeatingFactsheets, // correct name
          ),
        );

      case frostProtectionFactsheetsRoute:
        return MaterialPageRoute(
          builder: (_) => ProductFactsheetsScreen(
            categoryTitle: 'Frost Protection Factsheets',
            appBarColor: const Color(0xFF009ADC),
            factsheetData: frostProtectionFactsheets, // correct name
          ),
        );

      // Temporary placeholders for other routes
      case productInstructionCategorySelection:
      case caseStudies:
      case getAQuoteCategorySelection:
      case registerWarranty:
      case installerTools:
      case profile:
        return MaterialPageRoute(
          builder: (_) => _Stub(settings.name!.replaceFirst('/', '').replaceAll('_', ' ').toUpperCase()),
        );

      default:
        return MaterialPageRoute(builder: (_) => const _Stub('UNKNOWN ROUTE'));
    }
  }
}

class _Stub extends StatelessWidget {
  final String title;
  const _Stub(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, style: GoogleFonts.raleway())),
      body: const Center(child: Text('Coming soon...')),
    );
  }
}
