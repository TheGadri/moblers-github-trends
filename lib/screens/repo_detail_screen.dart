// Repository Detail Modal
import 'package:flutter/material.dart';
import 'package:moblers_github_trends/models/repo_model.dart';

class RepositoryDetailModal extends StatelessWidget {
  final RepoModel repository;
  final VoidCallback onFavoriteToggle;

  const RepositoryDetailModal({
    super.key,
    required this.repository,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      //TODO: Adjust the height as needed
      // height: MediaQuery.of(context).size.height * 0.8,
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
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFFF6F8FA),
                      child: Text(
                        repository.owner.login[0].toUpperCase(),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        repository.owner.login,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF24292E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailItem('Description', repository.description),
                if (repository.language != null)
                  _buildDetailItem('Language', repository.language!),
                _buildDetailItem(
                  'Stars',
                  _formatNumber(repository.stargazersCount),
                ),
                _buildDetailItem(
                  'Forks',
                  _formatNumber(repository.forksCount ?? 0),
                ),
                _buildDetailItem(
                  'Created',
                  _formatDate(repository.createdAt ?? DateTime.now()),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl('repository.htmlUrl'),
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
                      onFavoriteToggle();
                      Navigator.pop(context);
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
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF24292E),
            ),
          ),
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
    // if (await canLaunchUrl(Uri.parse(url))) {
    //   await launchUrl(Uri.parse(url));
    // }
  }
}
