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
import 'screens/heating_mat_planner.dart';
import 'screens/floor_diagrams.dart';
import 'screens/floor_sensor_calculator.dart';
import 'screens/thermostat_apps.dart';
import 'screens/cable_spacing_calculator_v3.dart';
import 'screens/get_a_quote.dart';
import 'screens/quote_form.dart';
import 'screens/quote_detail.dart';
import 'screens/installation_checklist_hub.dart';
import 'screens/heating_mat_checklist.dart';
import 'screens/heating_cable_checklist.dart';
import 'screens/register_warranty.dart';
import 'screens/installation_video_screen.dart';
import 'screens/loyalty_scheme_screen_v2.dart';

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
  static const underfloorHeatingFactsheetsRoute =
      '/underfloor_heating_factsheets';
  static const frostProtectionFactsheetsRoute = '/frost_protection_factsheets';

  // Instructions
  static const productInstructionCategorySelection =
      '/product_instruction_category_selection';
  static const underfloorHeatingInstructionsRoute =
      '/underfloor_heating_instructions';
  static const frostProtectionInstructionsRoute =
      '/frost_protection_instructions';

  // Installer Tools + subpages
  static const installerTools = '/installer_tools';
  static const heatingMatPlanner = '/heating_mat_planner';
  static const floorDiagrams = '/floor_diagrams';
  static const floorSensorCalculator = '/floor_sensor_calculator';
  static const cableSpacingCalculator = '/cable_spacing_calculator';
  static const installationVideo = '/installation_video';
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
  static const loyaltyScheme = '/loyalty_scheme';

  static Route<dynamic> _horizontalSlideRoute(
    RouteSettings settings,
    Widget page,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, animation, secondaryAnimation) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final incomingPosition = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);
        final outgoingPosition =
            Tween<Offset>(begin: Offset.zero, end: const Offset(-1, 0))
                .chain(CurveTween(curve: Curves.easeInOutCubic))
                .animate(secondaryAnimation);

        return SlideTransition(
          position: outgoingPosition,
          child: SlideTransition(position: incomingPosition, child: child),
        );
      },
    );
  }

  static Route<dynamic> _stationaryRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, animation, secondaryAnimation) => page,
    );
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // --- Entry / Auth ---
      case home:
        return _stationaryRoute(settings, const HomeScreen());

      case login:
        return _stationaryRoute(settings, const LoginScreen());

      case register:
        return _stationaryRoute(settings, const RegisterScreen());

      case resetPassword:
        return _stationaryRoute(settings, const ResetPasswordScreen());

      case profile:
        return _stationaryRoute(settings, const ProfileScreen());

      // --- Factsheets ---
      case productCategorySelection:
        return _horizontalSlideRoute(
          settings,
          const ProductCategorySelectionScreen(),
        );

      case underfloorHeatingFactsheetsRoute:
        return _horizontalSlideRoute(
          settings,
          ProductFactsheetsScreen(
            categoryTitle: 'Underfloor Heating Factsheets',
            appBarColor: const Color(0xFFDD4F2E),
            factsheetData:
                underfloorHeatingFactsheetsData, // keep your existing data source
          ),
        );

      case frostProtectionFactsheetsRoute:
        return _horizontalSlideRoute(
          settings,
          ProductFactsheetsScreen(
            categoryTitle: 'Frost Protection Factsheets',
            appBarColor: const Color(0xFF009ADC),
            factsheetData: frostProtectionFactsheetsData,
          ),
        );

      // --- Instructions ---
      case productInstructionCategorySelection:
        return _horizontalSlideRoute(
          settings,
          const InstructionCategorySelectionScreen(),
        );

      case underfloorHeatingInstructionsRoute:
        return _horizontalSlideRoute(
          settings,
          ProductInstructionsScreen(
            categoryTitle: 'Underfloor Heating Instructions',
            appBarColor: const Color(0xFFE26A2D),
            instructionData: underfloorHeatingInstructionsData,
          ),
        );

      case frostProtectionInstructionsRoute:
        return _horizontalSlideRoute(
          settings,
          ProductInstructionsScreen(
            categoryTitle: 'Frost Protection Instructions',
            appBarColor: const Color(0xFF009ADC),
            instructionData: frostProtectionInstructionsData,
          ),
        );

      // --- Installer Tools + subpages ---
      case installerTools:
        return _horizontalSlideRoute(settings, const InstallerToolsScreen());

      case heatingMatPlanner:
        return _horizontalSlideRoute(settings, const HeatingMatPlannerScreen());

      case floorDiagrams:
        return _horizontalSlideRoute(settings, const FloorDiagramsScreen());

      case floorSensorCalculator:
        return _horizontalSlideRoute(
          settings,
          const FloorSensorCalculatorScreen(),
        );

      case cableSpacingCalculator:
        return _horizontalSlideRoute(
          settings,
          const CableSpacingCalculatorScreen(),
        );

      case installationVideo:
        return _horizontalSlideRoute(settings, const InstallationVideoScreen());

      case thermostatApps:
        return _horizontalSlideRoute(settings, const ThermostatAppsScreen());

      case installationChecklistHub:
        return _horizontalSlideRoute(
          settings,
          const InstallationChecklistHubScreen(),
        );

      case heatingMatChecklist:
        return _horizontalSlideRoute(
          settings,
          const HeatingMatChecklistScreen(),
        );

      case heatingCableChecklist:
        return _horizontalSlideRoute(
          settings,
          const HeatingCableChecklistScreen(),
        );

      // --- Get a Quote hub (tabs) ---
      case getAQuoteCategorySelection:
        // Optional tab index via arguments (0=new quote, 1=saved)
        final initialTabIndex = (settings.arguments as int?) ?? 0;
        return _horizontalSlideRoute(
          settings,
          QuoteScreen(initialTabIndex: initialTabIndex),
        );

      // --- Quote Forms ---
      case underfloorHeatingQuote:
        return _horizontalSlideRoute(
          settings,
          const QuoteFormScreen(
            categoryTitle: 'Underfloor Heating Quote',
            appBarColor: Color(0xFFF8B637),
            categoryRoute: Routes.underfloorHeatingQuote,
          ),
        );

      case frostProtectionQuote:
        return _horizontalSlideRoute(
          settings,
          const QuoteFormScreen(
            categoryTitle: 'Frost Protection Quote',
            appBarColor: Color(0xFF009ADC),
            categoryRoute: Routes.frostProtectionQuote,
          ),
        );

      case mirrorDemisterQuote:
        return _horizontalSlideRoute(
          settings,
          const QuoteFormScreen(
            categoryTitle: 'Mirror Demister Quote',
            appBarColor: Color(0xFF8BC34A),
            categoryRoute: Routes.mirrorDemisterQuote,
          ),
        );

      case otherProductsQuote:
        return _horizontalSlideRoute(
          settings,
          const QuoteFormScreen(
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
        return _horizontalSlideRoute(settings, const CaseStudiesScreen());

      case caseStudyDetail:
        final id = settings.arguments as String?;
        return _horizontalSlideRoute(
          settings,
          CaseStudyDetailScreen(caseStudyId: id),
        );

      // --- Register Warranty ---
      case Routes.registerWarranty:
        final initialTab = (settings.arguments as int?) ?? 0;
        return _horizontalSlideRoute(
          settings,
          RegisterWarrantyScreen(initialTabIndex: initialTab),
        );

      case loyaltyScheme:
        return MaterialPageRoute(builder: (_) => const LoyaltySchemeScreen());

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
