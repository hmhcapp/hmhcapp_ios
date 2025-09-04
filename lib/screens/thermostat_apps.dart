import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

// Confirm/replace these App Store links if needed
const _tuyaSmartIOS = 'https://apps.apple.com/app/tuya-smart/id1034649547';
// Likely OWD5 iOS (please verify and replace if you have a different ID)
const _owd5IOS = 'https://apps.apple.com/app/id1547745880';

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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/diagonalpatternbg.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: gradient))),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: Text('Thermostat Apps', style: GoogleFonts.raleway()),
                  backgroundColor: const Color(0xFF333333),
                  foregroundColor: Colors.white,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: thermostatAppList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (_, i) => _ThermostatAppCard(app: thermostatAppList[i]),
                  ),
                ),
              ],
            ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header image (no badge)
            Padding(
              padding: EdgeInsets.only(top: widget.app.paddingTop),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  widget.app.imageAsset,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Titles
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                widget.app.thermostatName,
                style: GoogleFonts.raleway(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                widget.app.appName,
                style: GoogleFonts.raleway(fontSize: 15, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),

            // Expanded: Centered QR + App Store badge image (clickable)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: QrImageView(
                          data: widget.app.appStoreUrl,
                          version: QrVersions.auto,
                          size: 200,
                          gapless: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _openStore(widget.app.appStoreUrl),
                        child: Image.asset(
                          'assets/images/app_store_badge.png',
                          width: 180, // adjust if you want larger/smaller
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
      ),
    );
  }
}
