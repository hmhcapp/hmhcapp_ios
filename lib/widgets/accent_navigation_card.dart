import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccentNavigationCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? svgAsset;
  final Color accentColor;
  final VoidCallback onTap;

  const AccentNavigationCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.svgAsset,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(accentColor);
    final darkerColor = hsl
        .withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0))
        .toColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF191A1A), Color(0xFF262727)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.72),
              blurRadius: 15,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [darkerColor, accentColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.28),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: svgAsset == null
                          ? Icon(
                              icon,
                              size: 31,
                              color: Colors.white.withValues(alpha: 0.96),
                            )
                          : Center(
                              child: SvgPicture.asset(
                                svgAsset!,
                                width: 31,
                                height: 31,
                                colorFilter: ColorFilter.mode(
                                  Colors.white.withValues(alpha: 0.96),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.raleway(
                              color: Colors.white,
                              fontSize: 13.5,
                              height: 1.22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 30,
                            height: 2,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 22),
                  child: Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.raleway(
                      color: const Color(0xFFB5B5B5),
                      fontSize: 10.8,
                      height: 1.42,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: -3,
              bottom: -1,
              child: Icon(
                Icons.chevron_right_rounded,
                color: accentColor,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
