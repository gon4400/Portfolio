import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/project.dart';

PdfColor _pdfColor(Color c) => PdfColor.fromInt(c.toARGB32());
Future<pw.ThemeData> _buildPdfTheme() async {
  final base  = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  final bold  = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
  final emoji = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoEmoji-Regular.ttf'));
  return pw.ThemeData.withFont(
    base: base,
    bold: bold,
    fontFallback: [emoji],
  );
}
pw.PageTheme _buildPageTheme(pw.ThemeData theme, PdfColor surface) => pw.PageTheme(
  theme: theme,
  margin: const pw.EdgeInsets.all(24),
  buildBackground: (_) => pw.Container(color: surface),
);

String _stripEmojis(String s) {
  if (s.isEmpty) return s;
  final re = RegExp(
    r'(\u200D|\uFE0F|'                 // ZWJ + variation selector
    r'[\u{1F1E6}-\u{1F1FF}]|'          // drapeaux
    r'[\u{1F300}-\u{1FAD6}]|'          // pictos divers
    r'[\u{1F900}-\u{1F9FF}]|'          // Supplemental Symbols and Pictographs
    r'[\u{1FA70}-\u{1FAFF}]|'          // Symbols & Pictographs Ext-A
    r'[\u{2600}-\u{27BF}]'             // Misc symbols
    r')',
    unicode: true,
  );
  return s.replaceAll(re, '').replaceAll(RegExp(r'\s{2,}'), ' ').trim();
}

String _clip(String s, int max) => s.length <= max ? s : '${s.substring(0, max - 1)}…';

pw.Widget _header({
  required pw.ImageProvider profileImage,
  required String name,
  required String role,
  required String email,
  required PdfColor primary,
  required PdfColor onPrimary,
  required String Function(String) sanitize,
}) {
  return pw.Container(
    decoration: pw.BoxDecoration(color: primary, borderRadius: pw.BorderRadius.circular(8)),
    padding: const pw.EdgeInsets.all(12),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 64, height: 64,
          child: pw.ClipOval(child: pw.Image(profileImage, fit: pw.BoxFit.cover)),
        ),
        pw.SizedBox(width: 12),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(sanitize(name),
              style: pw.TextStyle(color: onPrimary, fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text(sanitize(role), style: pw.TextStyle(color: onPrimary)),
          pw.SizedBox(height: 2),
          pw.Text(email, style: pw.TextStyle(color: onPrimary, fontSize: 10)),
        ]),
      ],
    ),
  );
}

pw.Widget _projectItem(
    Project p, {
      required bool condensed,
      required PdfColor primary,
      required PdfColor surface,
      required PdfColor onSurface,
      required String Function(String) sanitize,
    }) {
  final title   = sanitize(p.title);
  final desc    = sanitize(p.description);
  final linkStr = sanitize(p.link);
  final clipped = _clip(desc, condensed ? 240 : 600);

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 10),
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: surface,
      border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.DefaultTextStyle(
      style: pw.TextStyle(color: onSurface),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: onSurface)),
        pw.SizedBox(height: 4),
        pw.Text(clipped, style: pw.TextStyle(fontSize: 11, color: onSurface)),
        if (p.link.trim().isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.UrlLink(
            destination: p.link, // conserve l’URL originale cliquable
            child: pw.Text(linkStr, style: pw.TextStyle(color: primary, fontSize: 10)),
          ),
        ],
      ]),
    ),
  );
}

Future<void> generateShortCV(
    BuildContext context,
    List<Project> projects,
    String email,
    String github,
    String linkedin, {
      bool keepEmojisInPdf = false,
    }) async {
  final l10n = AppLocalizations.of(context)!;
  final cs = Theme.of(context).colorScheme;
  final surfacePdf = _pdfColor(Theme.of(context).scaffoldBackgroundColor);
  final primary    = _pdfColor(cs.primary);
  final onPrimary  = _pdfColor(cs.onPrimary);
  final onSurface  = _pdfColor(cs.onSurface);

  final sanitize = keepEmojisInPdf ? (String s) => s : _stripEmojis;

  final pdf = pw.Document();
  final theme = await _buildPdfTheme();
  final pageTheme = _buildPageTheme(theme, surfacePdf);

  final img = await rootBundle.load('assets/images/profile.jpeg');
  final profileImage = pw.MemoryImage(img.buffer.asUint8List());

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      maxPages: 1,
      header: (ctx) => ctx.pageNumber == 1
          ? _header(
        profileImage: profileImage,
        name: 'Pierre Meignan',
        role: sanitize(l10n.cvRole),
        email: email,
        primary: primary,
        onPrimary: onPrimary,
        sanitize: sanitize,
      )
          : pw.SizedBox(),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          sanitize(l10n.cvPage(ctx.pageNumber, ctx.pagesCount)),
          style: pw.TextStyle(fontSize: 10, color: onSurface),
        ),
      ),
      build: (ctx) => [
        pw.SizedBox(height: 12),
        pw.DefaultTextStyle(
          style: pw.TextStyle(color: onSurface),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(sanitize(l10n.cvContacts),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: onSurface)),
              if (github.isNotEmpty)
                pw.Text('${sanitize(l10n.cvGithub)} : ${sanitize(github)}'),
              if (linkedin.isNotEmpty)
                pw.Text('${sanitize(l10n.cvLinkedIn)} : ${sanitize(linkedin)}'),
              pw.SizedBox(height: 14),
              pw.Text(
                sanitize(l10n.cvKeyProjects),
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primary),
              ),
              pw.SizedBox(height: 6),
              for (final p in projects.take(3))
                _projectItem(
                  p,
                  condensed: true,
                  primary: primary,
                  surface: surfacePdf,
                  onSurface: onSurface,
                  sanitize: sanitize,
                ),
            ],
          ),
        ),
      ],
    ),
  );

  await Printing.sharePdf(bytes: await pdf.save(), filename: 'CV_Pierre_Meignan_court.pdf');
}

Future<void> generateFullCV(
    BuildContext context,
    List<Project> projects,
    String email,
    String github,
    String linkedin, {
      bool keepEmojisInPdf = true,
    }) async {
  final l10n = AppLocalizations.of(context)!;
  final cs = Theme.of(context).colorScheme;
  final surfacePdf = _pdfColor(Theme.of(context).scaffoldBackgroundColor);
  final primary    = _pdfColor(cs.primary);
  final onPrimary  = _pdfColor(cs.onPrimary);
  final onSurface  = _pdfColor(cs.onSurface);

  final sanitize = keepEmojisInPdf ? (String s) => s : _stripEmojis;

  final pdf = pw.Document();
  final theme = await _buildPdfTheme();
  final pageTheme = _buildPageTheme(theme, surfacePdf);

  final img = await rootBundle.load('assets/images/profile.jpeg');
  final profileImage = pw.MemoryImage(img.buffer.asUint8List());

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      header: (ctx) => ctx.pageNumber == 1
          ? _header(
        profileImage: profileImage,
        name: 'Pierre Meignan',
        role: sanitize(l10n.cvRole),
        email: email,
        primary: primary,
        onPrimary: onPrimary,
        sanitize: sanitize,
      )
          : pw.SizedBox(),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          sanitize(l10n.cvPage(ctx.pageNumber, ctx.pagesCount)),
          style: pw.TextStyle(fontSize: 10, color: onSurface),
        ),
      ),
      build: (ctx) => [
        pw.SizedBox(height: 12),
        pw.DefaultTextStyle(
          style: pw.TextStyle(color: onSurface),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(sanitize(l10n.cvContacts),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: onSurface)),
              if (github.isNotEmpty)
                pw.Text('${sanitize(l10n.cvGithub)} : ${sanitize(github)}'),
              if (linkedin.isNotEmpty)
                pw.Text('${sanitize(l10n.cvLinkedIn)} : ${sanitize(linkedin)}'),
              pw.SizedBox(height: 16),
              pw.Text(
                sanitize(l10n.cvAllProjects),
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primary),
              ),
              pw.SizedBox(height: 8),
              for (final p in projects)
                _projectItem(
                  p,
                  condensed: false,
                  primary: primary,
                  surface: surfacePdf,
                  onSurface: onSurface,
                  sanitize: sanitize,
                ),
            ],
          ),
        ),
      ],
    ),
  );

  await Printing.sharePdf(bytes: await pdf.save(), filename: 'CV_Pierre_Meignan_complet.pdf');
}
