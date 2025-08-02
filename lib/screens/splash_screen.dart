import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/firebase_service.dart';
import '../screens/portfolio_screen.dart';
import '../utils/asset_maps.dart';
import '../utils/context_l10n.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  List<Project> _projects = [];
  String _linkedinUrl = '';
  String _githubUrl = '';
  String _email = '';
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      await _firebaseService.initialize();
      final locale = Localizations.localeOf(context);
      final localeCode = locale.toString().replaceAll('-', '_');
      final projects = _firebaseService.fetchProjects(
        imageAssets,
        animationAssets,
        localeCode: localeCode,
      );
      final linkedin = _firebaseService.linkedinUrl(localeCode);
      final github = _firebaseService.githubUrl(localeCode);
      final email = _firebaseService.email(localeCode);

      if (!mounted) return;
      setState(() {
        _projects = projects;
        _linkedinUrl = linkedin;
        _githubUrl = github;
        _email = email;
        _error = false;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      _navigateToHome();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = true);
      debugPrint('Error Remote Config: $e');
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PortfolioScreen(
          projects: _projects,
          linkedinUrl: _linkedinUrl,
          githubUrl: _githubUrl,
          email: _email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: _error
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(l10n.splashErrorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _error = false);
                _loadConfig();
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: l10n.appTitle,
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 120,
                height: 120,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(height: 30),
            Semantics(
              label: l10n.loading,
              child: const CircularProgressIndicator(strokeWidth: 3.5),
            ),
          ],
        ),
      ),
    );
  }
}
