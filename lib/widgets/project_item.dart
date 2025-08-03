import 'package:flutter/material.dart';
import '../models/project.dart';
import '../utils/context_l10n.dart';

class ProjectItem extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectItem({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface.withValues(alpha: 0.05);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalH = constraints.maxHeight.isFinite ? constraints.maxHeight : 220.0;
            const minTextH = 90.0;
            double imageH = totalH - minTextH;
            imageH = imageH.clamp(90.0, totalH * 0.7);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: imageH,
                  width: double.infinity,
                  child: Container(
                    color: bg,
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Semantics(
                      label: 'Logo ${project.title}',
                      child: Image.asset(
                        project.imageAsset,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        gaplessPlayback: true,
                        errorBuilder: (ctx, err, stack) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                // Titre + CTA
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onTap,
                          icon: Tooltip(
                            message: context.l10n.seeDetails,
                            child: const Icon(Icons.info_outline),
                          ),
                          label: Text(context.l10n.seeDetails),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
