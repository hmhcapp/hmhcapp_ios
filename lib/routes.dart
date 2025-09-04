import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'screens/product_category_selection.dart';
import 'screens/product_factsheets.dart';
import 'screens/product_instructions.dart';
import 'screens/instruction_category_selection.dart';
import 'screens/installer_tools.dart';
import 'screens/case_studies.dart';
import 'screens/case_study_detail.dart';
import 'screens/floor_diagrams.dart';
import 'screens/thermostat_apps.dart';

class Routes {
  static const home = '/';

  // Factsheets
  static const productCategorySelection = '/product_category_selection';
  static const underfloorHeatingFactsheetsRoute = '/underfloor_heating_factsheets';
  static const frostProtectionFactsheetsRoute = '/frost_protection_factsheets';

  // Instructions
  static const productInstructionCategorySelection = '/product_instruction_category_selection';
  static const underfloorHeatingInstructionsRoute = '/underfloor_heating_instructions';
  static const frostProtectionInstructionsRoute = '/frost_protection_instructions';

  // Installer Tools + sub-pages
  static const installerTools = '/installer_tools';
  static const floorDiagrams = '/floor_diagrams';
  static const cableSpacingCalculator = '/cable_spacing_calculator';
  static const thermostatApps = '/thermostat_apps';
  static const installationChecklistHub = '/installation_checklist_hub';

  // Others
  static const caseStudies = '/case_studies';
  static const caseStudyDetail = '/case_study_detail';
  static const getAQuoteCategorySelection = '/get_a_quote_category_selection';
  static const registerWarranty = '/register_warranty';
  static const profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // --- Factsheets ---
      case productCategorySelection:
        return MaterialPageRoute(builder: (_) => const ProductCategorySelectionScreen());

      case underfloorHeatingFactsheetsRoute:
        return MaterialPageRoute(
          builder: (_) => ProductFactsheetsScreen(
            categoryTitle: 'Underfloor Heating Factsheets',
            appBarColor: const Color(0xFFDD4F2E),
            factsheetData: underfloorHeatingFactsheetsData,
          ),
        );

      case frostProtectionFactsheetsRoute:
        return MaterialPageRoute(
          builder: (_) => ProductFactsheetsScreen(
            categoryTitle: 'Frost Protection Factsheets',
            appBarColor: const Color(0xFF009ADC),
            factsheetData: frostProtectionFactsheetsData,
          ),
        );

      // --- Instructions ---
      case productInstructionCategorySelection:
        return MaterialPageRoute(builder: (_) => const InstructionCategorySelectionScreen());

      case underfloorHeatingInstructionsRoute:
        return MaterialPageRoute(
          builder: (_) => ProductInstructionsScreen(
            categoryTitle: 'Underfloor Heating Instructions',
            appBarColor: const Color(0xFFE26A2D),
            instructionData: underfloorHeatingInstructionsData,
          ),
        );

      case frostProtectionInstructionsRoute:
        return MaterialPageRoute(
          builder: (_) => ProductInstructionsScreen(
            categoryTitle: 'Frost Protection Instructions',
            appBarColor: const Color(0xFF009ADC),
            instructionData: frostProtectionInstructionsData,
          ),
        );

       // --- Installer Tools ---
      case installerTools:
        return MaterialPageRoute(builder: (_) => const InstallerToolsScreen());

      case floorDiagrams:
        return MaterialPageRoute(builder: (_) => const FloorDiagramsScreen());

      case thermostatApps:
        return MaterialPageRoute(builder: (_) => const ThermostatAppsScreen());

      // Temporary placeholders for sub-pages (until implemented)
      case cableSpacingCalculator:
      case installationChecklistHub:
      case getAQuoteCategorySelection:
      case registerWarranty:
      case profile:
        return MaterialPageRoute(
          builder: (_) => _Stub(settings.name!.replaceFirst('/', '').replaceAll('_', ' ').toUpperCase()),
        );

      // --- Case Studies ---
      case caseStudies:
        return MaterialPageRoute(builder: (_) => const CaseStudiesScreen());

      case caseStudyDetail:
        final id = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => CaseStudyDetailScreen(caseStudyId: id));

      // --- Temporary placeholders for other routes ---
      case getAQuoteCategorySelection:
      case registerWarranty:
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
