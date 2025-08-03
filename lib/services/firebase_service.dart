import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../models/project.dart';

class FirebaseService {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await remoteConfig.fetchAndActivate();
  }

  List<Project> fetchProjects(
      Map<String, String> images,
      Map<String, String> animations, {
        required String localeCode,
      }) {
    const projectIds = [
      'tydom', 'portfolio', 'planchettes', 'info_traffic', 'kidizz',
      'mybatteryhealth_ios', 'mybatteryhealth_android', 't4u_ios', 't4u_android',
      'vinslocal', 'afpahotellerie', 'afparestaurant', 'proxiservices', 'wifibot',
    ];

    return projectIds
        .map((id) => Project.fromRemoteConfig(
      id,
      images,
      animations,
      remoteConfig,
      localeCode: localeCode,
    ))
        .toList();
  }

  String _getLocalized(String baseKey, String localeCode) {
    final lang = localeCode.split('_').first;
    for (final k in ['${baseKey}_$localeCode', '${baseKey}_$lang', baseKey]) {
      final v = remoteConfig.getString(k);
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  String linkedinUrl(String localeCode) => _getLocalized('linkedinLink', localeCode);
  String githubUrl(String localeCode)   => _getLocalized('githubLink', localeCode);
  String email(String localeCode)       => _getLocalized('email', localeCode);
}
