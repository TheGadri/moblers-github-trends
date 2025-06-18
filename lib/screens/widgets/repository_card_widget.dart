import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moblers_github_trends/models/repository_model.dart';
import 'package:moblers_github_trends/screens/widgets/user_avatar_widget.dart';

class RepositoryCard extends StatelessWidget {
  final RepositoryModel repository;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const RepositoryCard({
    super.key,
    required this.repository,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: .8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatarWidget(avatarUrl: repository.owner.avatarUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          repository.owner.login,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      repository.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: const Color(0xFFD73A49),
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                repository.description,
                style: textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFFFD700)),
                  const SizedBox(width: 4),
                  Text(
                    _formatNumber(repository.stargazersCount),

                    style: textTheme.bodyMedium,
                  ),
                  if (repository.language != null) ...[
                    const SizedBox(width: 16),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getLanguageColor(repository.language!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(repository.language!, style: textTheme.bodyMedium),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'typescript':
        return const Color(0xFF3178C6);
      case 'javascript':
        return const Color(0xFFF1E05A);
      case 'python':
        return const Color(0xFF3572A5);
      case 'dart':
        return const Color(0xFF00B4AB);
      case 'go':
        return const Color(0xFF00ADD8);
      default:
        return const Color(0xFF586069);
    }
  }
}
