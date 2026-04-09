import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.imageUrl,
    required this.defaultErrorAssetPath,
    super.key,
    this.isActive = false,
    this.hasBorder = false,
  });

  final String defaultErrorAssetPath;
  final String imageUrl;
  final bool isActive;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CircleAvatar(
          radius: 20.0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: CachedNetworkImage(
            placeholder: (context, url) => Skeletonizer(
              enabled: true,

              effect: ShimmerEffect(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                duration: Duration(seconds: 1),
              ),
              child: CircleAvatar(
                radius: hasBorder ? 17.0 : 20.0,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            errorWidget: (context, url, error) => CircleAvatar(
              radius: hasBorder ? 17.0 : 20.0,
              backgroundColor: Colors.grey.shade200,
              child: Image.asset(
                defaultErrorAssetPath,
                fit: BoxFit.fill,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            fit: BoxFit.fill,
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) {
              return CircleAvatar(
                radius: hasBorder ? 17.0 : 20.0,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: imageProvider,
              );
            },
          ),
        ),
        isActive
            ? Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Container(
                  height: 15.0,
                  width: 15.0,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(width: 2.0, color: Colors.white),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
