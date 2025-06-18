import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moblers_github_trends/models/repository_model.dart';

class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({super.key, required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFF6F8FA),
      foregroundImage: CachedNetworkImageProvider(repository.owner.avatarUrl),
      child: CachedNetworkImage(
        imageUrl: repository.owner.avatarUrl,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) =>
            Text(repository.owner.login[0].toUpperCase()),
      ),
    );
  }
}
