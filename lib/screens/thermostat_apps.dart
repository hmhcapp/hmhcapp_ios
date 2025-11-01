import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ThermostatAppData {
  final String thermostatName;
  final String appName;
  final String imageAsset;   // e.g. assets/images/hmt5_wifi.png
  final String iosUrl;       // Apple App Store URL
  final String androidUrl;   // Google Play URL
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
bool get _isAndroid => !kIsWeb && Platform.isAndroid;

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

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.4),
        const Color(0xFF333333).withOpacity(0.6),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Thermostat Apps', style: GoogleFonts.raleway()),
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/diagonalpatternbg.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(decoration: BoxDecoration(gradient: gradient)),
          ),
          Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                  itemCount: thermostatAppList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (_, i) => _ThermostatAppCard(app: thermostatAppList[i]),
                ),
              ),
            ],
          ),
        ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.95),
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
                  padding: EdgeInsets.only(top: widget.app.paddingTop > 0 ? widget.app.paddingTop : 20),
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
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    widget.app.appName,
                    style: GoogleFonts.raleway(fontSize: 15, color: Colors.black54),
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
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.transparent),
                            ),
                            child: QrImageView(
                              data: storeUrl,        // QR points to the correct store for platform
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
                  crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
                  color: Colors.white.withOpacity(0),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0),
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
