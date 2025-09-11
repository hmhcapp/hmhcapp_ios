import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ThermostatAppData {
  final String thermostatName;
  final String appName;
  final String imageAsset;   // e.g. assets/images/hmt5_wifi.png
  final String appStoreUrl;  // Apple App Store URL
  final double paddingTop;
  const ThermostatAppData({
    required this.thermostatName,
    required this.appName,
    required this.imageAsset,
    required this.appStoreUrl,
    this.paddingTop = 0,
  });
}

const _tuyaSmartIOS = 'https://apps.apple.com/app/tuya-smart/id1034649547';
const _owd5IOS = 'https://apps.apple.com/app/oj-microline-owd5/id1326069503';

final List<ThermostatAppData> thermostatAppList = [
  ThermostatAppData(
    thermostatName: 'HMT5 Wifi Thermostat',
    appName: 'Uses Tuya Smart App',
    imageAsset: 'assets/images/hmt5_wifi.png',
    appStoreUrl: _tuyaSmartIOS,
  ),
  ThermostatAppData(
    thermostatName: 'HMH200 Wifi Thermostat',
    appName: 'Uses Tuya Smart App',
    imageAsset: 'assets/images/hmh200_wifi.png',
    appStoreUrl: _tuyaSmartIOS,
  ),
  ThermostatAppData(
    thermostatName: 'NGT-3.0-WIFI Wifi Thermostat',
    appName: 'Uses OWD5 App',
    imageAsset: 'assets/images/ngt_wifi.png',
    appStoreUrl: _owd5IOS,
    paddingTop: 8,
  ),
];

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
                              data: widget.app.appStoreUrl,
                              version: QrVersions.auto,
                              size: 180,
                              gapless: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _openStore(widget.app.appStoreUrl),
                            child: Image.asset(
                              'assets/images/app_store_badge.png',
                              width: 200,
                              fit: BoxFit.contain,
                              semanticLabel: 'Open in the App Store',
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

            // Apple PNG badge (top-right)
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
                  'assets/images/apple_glyph_dark.png', // <-- add to pubspec assets
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
