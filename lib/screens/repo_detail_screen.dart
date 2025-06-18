import 'package:flutter/material.dart';
import 'package:moblers_github_trends/providers/repo_detail_provider.dart';
import 'package:moblers_github_trends/screens/widgets/user_avatar_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RepositoryDetailModal extends StatelessWidget {
  const RepositoryDetailModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Consumer<RepoDetailProvider>(
      builder: (context, repoDetailProvider, child) {
        final repository = repoDetailProvider.repository;

        return Container(
          height: MediaQuery.sizeOf(context).height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserAvatarWidget(avatarUrl: repository.owner.avatarUrl),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            repository.owner.login,
                            style: textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDetailItem(
                      context,
                      'Description',
                      repository.description,
                    ),
                    if (repository.language != null)
                      _buildDetailItem(
                        context,
                        'Language',
                        repository.language!,
                      ),
                    _buildDetailItem(
                      context,
                      'Stars',
                      _formatNumber(repository.stargazersCount),
                    ),
                    _buildDetailItem(
                      context,
                      'Forks',
                      _formatNumber(repository.forksCount),
                    ),
                    _buildDetailItem(
                      context,
                      'Created',
                      _formatDate(repository.createdAt),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(repository.htmlUrl),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('View on GitHub'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0366D6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!repoDetailProvider.isTogglingFavorite) {
                            repoDetailProvider.toggleFavoriteStatus();
                          }
                        },
                        icon: Icon(
                          repository.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        label: Text(
                          repository.isFavorite
                              ? 'Remove from Favorites'
                              : 'Add to Favorites',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD73A49),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Color(0xFF586069)),
          ),
        ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _launchUrl(String url) async {
    await launchUrl(Uri.parse(url));
  }
}
