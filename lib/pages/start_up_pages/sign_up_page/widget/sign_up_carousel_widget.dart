import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class SignUpCarouselWidget extends StatelessWidget {
  const SignUpCarouselWidget({
    super.key,
    required this.size,
    required this.images,
    required this.appLogoLight,
  });

  final Size size;
  final List<String> images;
  final Widget appLogoLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.only(
        left: 5.0,
        top: 10,
        bottom: 10,
        right: 5.0,
      ),
      child: Stack(
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: AbsorbPointer(
                child: CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    aspectRatio: 16 / 9,
                    pauseAutoPlayOnTouch: true,
                    initialPage: 0,
                    pauseAutoPlayInFiniteScroll: false,
                    autoPlayAnimationDuration: const Duration(
                      seconds: 1,
                    ),
                    viewportFraction: 1.0,
                    height: size.height,
                  ),
                  items: images.map((image) {
                    return Builder(
                      builder: (BuildContext context) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(
                            5.0,
                          ),
                          child: Container(
                            width: size.width,
                            height: size.height,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Image.asset(
                              image,
                              fit: BoxFit.fill,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10.0,
                  sigmaY: 10.0,
                ),
                child: Container(
                  height: size.height * .35,
                  width: size.width * .4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: size.width * .4,
                        height: size.height * .35,
                        child: appLogoLight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
