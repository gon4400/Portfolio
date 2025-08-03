import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/project.dart';
import '../widgets/project_item.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/cv_generator.dart';
import '../utils/context_l10n.dart';

class PortfolioScreen extends StatefulWidget {
  final List<Project> projects;
  final String linkedinUrl;
  final String githubUrl;
  final String email;

  const PortfolioScreen({
    super.key,
    required this.projects,
    required this.linkedinUrl,
    required this.githubUrl,
    required this.email,
  });

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final ScrollController _scrollController = ScrollController();
  int? selectedProjectIndex;

  final _aboutKey = GlobalKey();
  final _skillsKey = GlobalKey();
  final _projectsKey = GlobalKey();
  final _contactKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.02,
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAboutMe() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context.l10n.aboutTitle),
        Text(
          context.l10n.aboutParagraph,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),

        Container(key: _skillsKey),

        _chipGroup(context.l10n.skillsGroupStack, const [
          "Flutter", "Dart",
          "Kotlin", "Jetpack Compose",
          "Swift", "SwiftUI",
          "Android", "iOS",
        ]),

        _chipGroup(context.l10n.skillsGroupArch, const [
          "Clean Architecture", "SOLID", "MVVM",
          "BLoC", "Riverpod", "Provider",
          "DI (Dagger2/Hilt/Koin)", "Navigation (Compose/Flutter)",
        ]),

        _chipGroup(context.l10n.skillsGroupApis, const [
          "REST", "GraphQL", "WebSockets",
          "JSON", "OAuth2", "Room/SQLite", "CoreData", "SharedPreferences",
        ]),

        _chipGroup(context.l10n.skillsGroupCloud, const [
          "Firebase Remote Config", "Crashlytics", "Analytics",
          "App Distribution", "FCM (Push)",
        ]),

        _chipGroup(context.l10n.skillsGroupCICD, const [
          "Git", "GitHub", "GitLab CI", "Bitrise",
          "Fastlane", "Play Console", "App Store Connect",
          "Code Review", "SonarQube", "Linting",
        ]),

        _chipGroup(context.l10n.skillsGroupQuality, const [
          "Unit Tests", "Widget/Integration Tests", "Espresso/XCTest",
          "TDD", "R8/ProGuard", "HTTPS",
        ]),

        _chipGroup(context.l10n.skillsGroupUX, const [
          "Material 3", "Design System",
          "Animations", "Lottie",
        ]),
      ],
    );
  }

  Widget _chipGroup(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((s) => Tooltip(
            message: s,
            child: Chip(label: Text(s)),
          ))
              .toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _openImageViewer(String assetPath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.7,
              maxScale: 4,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Tooltip(
                message: context.l10n.close,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedProjectView(Project project) {
    final String screenshot =
    (project.animation != 'assets/images/default.jpg' &&
        project.animation.isNotEmpty)
        ? project.animation
        : project.imageAsset;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              onTap: () => _openImageViewer(screenshot),
              child: Image.asset(
                screenshot,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _openImageViewer(screenshot),
                icon: Tooltip(
                  message: context.l10n.enlargeImage,
                  child: const Icon(Icons.zoom_out_map),
                ),
                label: Text(context.l10n.enlargeImage),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectSection() {
    return Column(
      key: _projectsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context.l10n.projectsTitle),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: selectedProjectIndex == null
              ? LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final crossAxisCount = w >= 1100 ? 3 : (w >= 700 ? 2 : 1);
              final cardAspectRatio =
              w >= 1100 ? 1.15 : (w >= 700 ? 0.95 : 0.80);

              return GridView.builder(
                key: const ValueKey("grid"),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: cardAspectRatio,
                ),
                itemCount: widget.projects.length,
                itemBuilder: (context, index) {
                  return ProjectItem(
                    project: widget.projects[index],
                    onTap: () {
                      setState(() => selectedProjectIndex = index);
                      _scrollToSection(_projectsKey);
                    },
                  );
                },
              );
            },
          )
              : Builder(
            key: const ValueKey("detail"),
            builder: (_) {
              if (selectedProjectIndex == null ||
                  selectedProjectIndex! < 0 ||
                  selectedProjectIndex! >= widget.projects.length) {
                return const SizedBox.shrink();
              }
              final project = widget.projects[selectedProjectIndex!];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExpandedProjectView(project),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (project.link.trim().isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () async {
                            final url = Uri.parse(project.link);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          icon: Tooltip(
                            message: context.l10n.seeProject,
                            child: const Icon(Icons.open_in_new),
                          ),
                          label: Text(context.l10n.seeProject),
                        ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => selectedProjectIndex = null);
                          _scrollToSection(_projectsKey);
                        },
                        icon: const Icon(Icons.close),
                        label: Text(context.l10n.collapse),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      key: _contactKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context.l10n.contactTitle),
        ElevatedButton.icon(
          onPressed: () => launchUrl(Uri.parse('mailto:${widget.email}')),
          icon: const Icon(Icons.email),
          label: Text(context.l10n.sendEmail),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => launchUrl(Uri.parse(widget.linkedinUrl)),
          icon: const Icon(Icons.web),
          label: Text(context.l10n.seeLinkedIn),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => launchUrl(Uri.parse(widget.githubUrl)),
          icon: const Icon(Icons.code),
          label: Text(context.l10n.seeGitHub),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => generateShortCV(
            context,
            widget.projects,
            widget.email,
            widget.githubUrl,
            widget.linkedinUrl,
          ),
          icon: const Icon(Icons.picture_as_pdf),
          label: Text(context.l10n.downloadShortCV),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => generateFullCV(
            context,
            widget.projects,
            widget.email,
            widget.githubUrl,
            widget.linkedinUrl,
          ),
          icon: const Icon(Icons.picture_as_pdf),
          label: Text(context.l10n.downloadFullCV),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onAbout:   () => _scrollToSection(_aboutKey),
        onSkills:  () => _scrollToSection(_skillsKey),
        onProjects:() => _scrollToSection(_projectsKey),
        onContact: () => _scrollToSection(_contactKey),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/profile.jpeg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.greeting,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.tagline,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            KeyedSubtree(key: _aboutKey, child: _buildAboutMe()),
            const SizedBox(height: 20),

            _buildProjectSection(),
            const SizedBox(height: 20),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }
}
