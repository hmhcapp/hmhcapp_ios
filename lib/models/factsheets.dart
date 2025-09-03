import 'package:flutter/foundation.dart';

@immutable
class PdfInfo {
  final String name;
  final String url; // supports gs:// or https://
  const PdfInfo(this.name, this.url);
}

@immutable
class CategoryData {
  final String title;
  final List<ContentItem> items;
  const CategoryData(this.title, this.items);
}

@immutable
abstract class ContentItem {
  const ContentItem();

  const factory ContentItem.subCategory(String title, List<PdfInfo> pdfs) =
      SubCategory;

  const factory ContentItem.pdf(PdfInfo info) = PdfItem;
}

class SubCategory implements ContentItem {
  final String title;
  final List<PdfInfo> pdfs;
  const SubCategory(this.title, this.pdfs);
}

class PdfItem implements ContentItem {
  final PdfInfo info;
  const PdfItem(this.info);
}

/// Convert `gs://bucket/path/to/file.pdf` to a public https download URL.
String gsToHttps(String url) {
  if (!url.startsWith('gs://')) return url;
  final s = url.substring(5); // strip 'gs://'
  final slash = s.indexOf('/');
  if (slash < 0) return url;
  final bucket = s.substring(0, slash);
  final path = s.substring(slash + 1);
  final encPath = Uri.encodeComponent(path);
  return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encPath?alt=media';
}

/// ---------- DATA (ported from your Kotlin) ----------
final List<CategoryData> underfloorHeatingFactsheets = [
  CategoryData("Heating Mats", [
    const SubCategory("Heat Mat Pro", [
      // PdfInfo("PKM-065 factsheet", "gs://.../PKM-065....pdf"),
      PdfInfo("PKM-110 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-110W-heating-mat-factsheet.pdf"),
      PdfInfo("PKM-160 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-160W-heating-mat-factsheet.pdf"),
      PdfInfo("PKM-200 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-200W-heating-mat-factsheet.pdf"),
      PdfInfo("PKM-240 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKM/Heat-Mat-PKM-240W-heating-mat-factsheet.pdf"),
    ]),
    const SubCategory("Heat My Home", [
      PdfInfo("HMH160W factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/HMHMAT/Heat-My-Home-HMHMAT-factsheet.pdf"),
    ]),
  ]),
  CategoryData("Heating Cables", [
    const SubCategory("Heat Mat Pro", [
      PdfInfo("PKC-3.0 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKC/Heat-Mat-PKC-3mm-cable-factsheet.pdf"),
      PdfInfo("PKC-5.0 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/PKC/Heat-Mat-PKC-5mm-cable-factsheet.pdf"),
    ]),
    const SubCategory("Heat My Home", [
      PdfInfo("HMHCAB factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/HMHCAB/Heat-My-Home-HMHCAB-factsheet.pdf"),
    ]),
  ]),
  CategoryData("Combymat/Foil Heating", const [
    PdfItem(PdfInfo("CBM-150 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/CBM/Heat-Mat-CBM-Combymat-factsheet.pdf")),
    PdfItem(PdfInfo("CBM-OVE factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/CBM/Heat-Mat-CBM-Combymat-overlay-boards-factsheet.pdf")),
  ]),
  CategoryData("Thermostats", const [
    PdfItem(PdfInfo("HMT5 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/HMT5/Heat-Mat-HMT5-thermostat-factsheet.pdf")),
    PdfItem(PdfInfo("HMH200 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/HMH200/Heat-My-Home-HMH200-Wifi-Thermostat-Factsheet.pdf")),
    PdfItem(PdfInfo("HMH100 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/HMH100/Heat-My-Home-HMH100-Wifi-Thermostat-Factsheet.pdf")),
    PdfItem(PdfInfo("NGTouch factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/NGT/Heat-Mat-NGTouch-thermostat-factsheet.pdf")),
    PdfItem(PdfInfo("NGTWifi factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/NGTWIFI/Heat-Mat-NGTouch-wifi-thermostat-factsheet.pdf")),
    PdfItem(PdfInfo("TPS32 factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/THERMOSTATS/TPS/Heat-Mat-TPS31-thermostat-factsheet.pdf")),
  ]),
  CategoryData("Insulation Boards", const [
    PdfItem(PdfInfo("TTB Insulation factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/TTB/Heat-Mat-TTB-insulation-board-factsheet.pdf")),
  ]),
];

final List<CategoryData> frostProtectionFactsheets = [
  CategoryData("Trace Heating", const [
    PdfItem(PdfInfo("Trace Heating Cable factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/ICEANDSNOW/Trace-Heating-Factsheet.pdf")),
  ]),
  CategoryData("Pipe Protection", const [
    PdfItem(PdfInfo("PipeGuard factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/ICEANDSNOW/PipeGuard_Factsheet.pdf")),
  ]),
  CategoryData("Gutter & Roof Heating", const [
    PdfItem(PdfInfo("Gutter and Roof Heating Cable factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/ICEANDSNOW/Roof-and-gutter-heating-factsheet.pdf")),
  ]),
  CategoryData("Driveway & Ramp Heating", const [
    PdfItem(PdfInfo("Driveway Heating Cable factsheet", "gs://hm-hc-app.firebasestorage.app/FACTSHEETS/ICEANDSNOW/Heat-Mat-50W-Snow-Melting-Cable-Factsheet.pdf")),
  ]),
];
