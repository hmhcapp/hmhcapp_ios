import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Home
import 'package:hmhcapp_ios/main_home.dart';

// Screens
import 'screens/product_category_selection.dart';
import 'screens/product_factsheets.dart';
import 'screens/product_instructions.dart';
import 'screens/instruction_category_selection.dart';
import 'screens/case_studies.dart';
import 'screens/case_study_detail.dart';
import 'screens/installer_tools.dart';
import 'screens/floor_diagrams.dart';
import 'screens/thermostat_apps.dart';
import 'screens/cable_spacing_calculator.dart';
import 'screens/get_a_quote.dart';
import 'screens/quote_form.dart';
import 'screens/quote_detail.dart';
import 'screens/installation_checklist_hub.dart';
import 'screens/heating_mat_checklist.dart';
import 'screens/heating_cable_checklist.dart';
import 'screens/register_warranty.dart';

// Auth
import 'package:hmhcapp_ios/auth/login_screen.dart';
import 'package:hmhcapp_ios/auth/register_screen.dart';
import 'package:hmhcapp_ios/auth/reset_password_screen.dart';
import 'package:hmhcapp_ios/auth/profile_screen.dart';

class Routes {
  // Entry points
  static const home = '/home';
  static const profile = '/profile';
  static const login = '/login';
  static const register = '/register';
  static const resetPassword = '/reset_password';

  // Factsheets
  static const productCategorySelection = '/product_category_selection';
  static const underfloorHeatingFactsheetsRoute = '/underfloor_heating_factsheets';
  static const frostProtectionFactsheetsRoute = '/frost_protection_factsheets';

  // Instructions
  static const productInstructionCategorySelection = '/product_instruction_category_selection';
  static const underfloorHeatingInstructionsRoute = '/underfloor_heating_instructions';
  static const frostProtectionInstructionsRoute = '/frost_protection_instructions';

  // Installer Tools + subpages
  static const installerTools = '/installer_tools';
  static const floorDiagrams = '/floor_diagrams';
  static const cableSpacingCalculator = '/cable_spacing_calculator';
  static const thermostatApps = '/thermostat_apps';
  static const installationChecklistHub = '/installation_checklist_hub';
  static const heatingMatChecklist = '/heating_mat_checklist';
  static const heatingCableChecklist = '/heating_cable_checklist';

  // Get a Quote hub + forms
  static const getAQuoteCategorySelection = '/get_a_quote_category_selection';
  static const underfloorHeatingQuote = '/underfloor_heating_quote';
  static const frostProtectionQuote = '/frost_protection_quote';
  static const mirrorDemisterQuote = '/mirror_demister_quote';
  static const otherProductsQuote = '/other_products_quote';
  static const quoteDetail = '/quote_detail';

  // Others
  static const caseStudies = '/case_studies';
  static const caseStudyDetail = '/case_study_detail';
  static const registerWarranty = '/register_warranty';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // --- Entry / Auth ---
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      // --- Factsheets ---
      case productCategorySelection:
        return MaterialPageRoute(builder: (_) => const ProductCategorySelectionScreen());

      case underfloorHeatingFactsheetsRoute:
        return MaterialPageRoute(
          builder: (_) => ProductFactsheetsScreen(
            categoryTitle: 'Underfloor Heating Factsheets',
            appBarColor: const Color(0xFFDD4F2E),
            factsheetData: underfloorHeatingFactsheetsData, // keep your existing data source
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

      // --- Installer Tools + subpages ---
      case installerTools:
        return MaterialPageRoute(builder: (_) => const InstallerToolsScreen());

      case floorDiagrams:
        return MaterialPageRoute(builder: (_) => const FloorDiagramsScreen());

      case cableSpacingCalculator:
        return MaterialPageRoute(builder: (_) => const CableSpacingCalculatorScreen());

      case thermostatApps:
        return MaterialPageRoute(builder: (_) => const ThermostatAppsScreen());

      case installationChecklistHub:
        return MaterialPageRoute(builder: (_) => const InstallationChecklistHubScreen());

      case heatingMatChecklist:
        return MaterialPageRoute(builder: (_) => const HeatingMatChecklistScreen());

      case heatingCableChecklist:
        return MaterialPageRoute(builder: (_) => const HeatingCableChecklistScreen());

      // --- Get a Quote hub (tabs) ---
      case getAQuoteCategorySelection:
        // Optional tab index via arguments (0=new quote, 1=saved)
        final initialTabIndex = (settings.arguments as int?) ?? 0;
        return MaterialPageRoute(
          builder: (_) => QuoteScreen(initialTabIndex: initialTabIndex),
        );

      // --- Quote Forms ---
      case underfloorHeatingQuote:
        return MaterialPageRoute(
          builder: (_) => const QuoteFormScreen(
            categoryTitle: 'Underfloor Heating Quote',
            appBarColor: Color(0xFFF8B637),
            categoryRoute: Routes.underfloorHeatingQuote,
          ),
        );

      case frostProtectionQuote:
        return MaterialPageRoute(
          builder: (_) => const QuoteFormScreen(
            categoryTitle: 'Frost Protection Quote',
            appBarColor: Color(0xFF009ADC),
            categoryRoute: Routes.frostProtectionQuote,
          ),
        );

      case mirrorDemisterQuote:
        return MaterialPageRoute(
          builder: (_) => const QuoteFormScreen(
            categoryTitle: 'Mirror Demister Quote',
            appBarColor: Color(0xFF8BC34A),
            categoryRoute: Routes.mirrorDemisterQuote,
          ),
        );

      case otherProductsQuote:
        return MaterialPageRoute(
          builder: (_) => const QuoteFormScreen(
            categoryTitle: 'Other Products Quote',
            appBarColor: Color(0xFFE88A2B),
            categoryRoute: Routes.otherProductsQuote,
          ),
        );

      // --- Quote Detail ---
      case quoteDetail:
        final id = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => QuoteDetailScreen(quoteId: id),
        );

      // --- Case Studies ---
      case caseStudies:
        return MaterialPageRoute(builder: (_) => const CaseStudiesScreen());

      case caseStudyDetail:
        final id = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => CaseStudyDetailScreen(caseStudyId: id));

      // --- Register Warranty ---
      case Routes.registerWarranty:
  final initialTab = (settings.arguments as int?) ?? 0;
  return MaterialPageRoute(builder: (_) => RegisterWarrantyScreen(initialTabIndex: initialTab));

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
