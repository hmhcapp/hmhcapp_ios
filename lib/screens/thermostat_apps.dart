import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../widgets/atmospheric_dark_background.dart';
import 'package:url_launcher/url_launcher.dart';

class ThermostatAppData {
  final String thermostatName;
  final String appName;
  final String imageAsset; // e.g. assets/images/hmt5_wifi.png
  final String iosUrl; // Apple App Store URL
  final String androidUrl; // Google Play URL
  final double paddingTop;

  const ThermostatAppData({
    required this.thermostatName,
    required this.appName,
    required this.imageAsset,
    required this.iosUrl,
    required this.androidUrl,
    this.paddingTop = 0,
  });
}

// iOS
const _tuyaSmartIOS = 'https://apps.apple.com/app/tuya-smart/id1034649547';
const _owd5IOS = 'https://apps.apple.com/app/oj-microline-owd5/id1326069503';

// ANDROID (replace the placeholders below with your exact Play IDs if needed)
const _tuyaSmartAndroid =
    'https://play.google.com/store/apps/details?id=com.tuya.smart&utm_source=emea_Med';
const _owd5Android =
    'https://play.google.com/store/apps/details?id=com.ojelectronics.owd5&utm_source=emea_Med';

final List<ThermostatAppData> thermostatAppList = [
  ThermostatAppData(
    thermostatName: 'HMT5 Wifi Thermostat',
    appName: 'Uses Tuya Smart App',
    imageAsset: 'assets/images/hmt5_wifi.png',
    iosUrl: _tuyaSmartIOS,
    androidUrl: _tuyaSmartAndroid,
  ),
  ThermostatAppData(
    thermostatName: 'HMH200 Wifi Thermostat',
    appName: 'Uses Tuya Smart App',
    imageAsset: 'assets/images/hmh200_wifi.png',
    iosUrl: _tuyaSmartIOS,
    androidUrl: _tuyaSmartAndroid,
  ),
  ThermostatAppData(
    thermostatName: 'NGT-3.0-WIFI Wifi Thermostat',
    appName: 'Uses OWD5 App',
    imageAsset: 'assets/images/ngt_wifi.png',
    iosUrl: _owd5IOS,
    androidUrl: _owd5Android,
    paddingTop: 8,
  ),
];

bool get _isIOS => !kIsWeb && Platform.isIOS;

/// Chooses the correct store URL for the current platform (defaults to Android on web).
String _storeUrlForPlatform(ThermostatAppData app) {
  if (_isIOS) return app.iosUrl;
  return app.androidUrl;
}

/// Badge asset for the current platform (defaults to Google Play on web).
String _badgeAssetForPlatform() {
  if (_isIOS) return 'assets/images/app_store_badge.png';
  return 'assets/images/google_play_badge.png';
}

/// Badge alt text for the current platform.
String _badgeSemanticForPlatform() {
  if (_isIOS) return 'Open in the App Store';
  return 'Get it on Google Play';
}

/// Top-right logo for the current platform.
String _cornerLogoForPlatform() {
  if (_isIOS) return 'assets/images/apple_glyph_dark.png';
  return 'assets/images/google_play_logo.png';
}

class ThermostatAppsScreen extends StatelessWidget {
  const ThermostatAppsScreen({super.key});

  static const _accentColor = Color(0xFFE9882A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Thermostat Apps',
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Find the correct app for your thermostat',
              style: GoogleFonts.raleway(
                color: atmosphericSecondaryText,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF101111),
        foregroundColor: _accentColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 64,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _accentColor,
            size: 30,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.phone_android_rounded, color: _accentColor),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: AtmosphericDarkBackground(
        accentColor: _accentColor,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 90),
          itemCount: thermostatAppList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (_, i) => _ThermostatAppCard(app: thermostatAppList[i]),
        ),
      ),
    );
  }
}

class _ThermostatAppCard extends StatefulWidget {
  final ThermostatAppData app;
  const _ThermostatAppCard({required this.app});

  @override
  State<_ThermostatAppCard> createState() => _ThermostatAppCardState();
}

class _ThermostatAppCardState extends State<_ThermostatAppCard> {
  bool expanded = false;

  Future<void> _openStore(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final storeUrl = _storeUrlForPlatform(widget.app);
    final badgeAsset = _badgeAssetForPlatform();
    final badgeSemantic = _badgeSemanticForPlatform();
    final cornerLogo = _cornerLogoForPlatform();

    return Card(
      elevation: 6,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: atmosphericBorder),
      ),
      color: atmosphericSurface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => expanded = !expanded),
        child: Stack(
          clipBehavior: Clip.none, // ensure overlays aren’t clipped
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: widget.app.paddingTop > 0 ? widget.app.paddingTop : 20,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      widget.app.imageAsset,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    widget.app.thermostatName,
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: atmosphericPrimaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    widget.app.appName,
                    style: GoogleFonts.raleway(
                      fontSize: 15,
                      color: atmosphericSecondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E2E2),
                              ),
                            ),
                            child: QrImageView(
                              data:
                                  storeUrl, // QR points to the correct store for platform
                              version: QrVersions.auto,
                              size: 180,
                              gapless: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _openStore(storeUrl),
                            child: Image.asset(
                              badgeAsset,
                              width: 200,
                              fit: BoxFit.contain,
                              semanticLabel: badgeSemantic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),

            // Corner store logo (Apple on iOS, Play on Android/Web)
            Positioned(
              top: 0,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Image.asset(
                  cornerLogo,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
