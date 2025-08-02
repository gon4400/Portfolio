import 'package:firebase_remote_config/firebase_remote_config.dart';

class Project {
  final String title;
  final String description;
  final String imageAsset;
  final String animation;
  final String link;

  Project({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.animation,
    required this.link,
  });

  static String _rcGetLocalized(
      FirebaseRemoteConfig rc,
      String baseKey,
      String localeCode,
      ) {
    final lang = localeCode.split('_').first;
    final candidates = <String>[
      '${baseKey}_$localeCode',
      '${baseKey}_$lang',
      baseKey,
    ];
    for (final k in candidates) {
      final v = rc.getString(k);
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  factory Project.fromRemoteConfig(
      String id,
      Map<String, String> images,
      Map<String, String> animations,
      FirebaseRemoteConfig rc, {
        required String localeCode,
      }) {
    final base = 'project_$id';
    final title = _rcGetLocalized(rc, '${base}_title', localeCode);
    final description = _rcGetLocalized(rc, '${base}_description', localeCode);
    final link = _rcGetLocalized(rc, '${base}_link', localeCode);

    return Project(
      title: title,
      description: description,
      imageAsset: images[id] ?? 'assets/images/default.jpg',
      animation: animations[id] ?? 'assets/images/default.jpg',
      link: link,
    );
  }
}
