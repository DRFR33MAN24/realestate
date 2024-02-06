import 'package:ebroker/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/default_app_setting.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/ui_utils.dart';

class FullScreenImageView extends StatefulWidget {
  final ImageProvider provider;
  const FullScreenImageView({
    super.key,
    required this.provider,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

        Navigator.pop(context);
      },
      child: SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: context.color.tertiaryColor),
          ),
          backgroundColor: const Color.fromARGB(17, 0, 0, 0),
          body: InteractiveViewer(
            maxScale: 4,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: GestureDetector(
                  onTap: () {},
                  child: Image(
                    image: widget.provider,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              color:
                                  context.color.tertiaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10)),
                          child: LoadAppSettings().svg(
                              appSettings.placeholderLogo!,
                              color: context.color.tertiaryColor));
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return FittedBox(
                        fit: BoxFit.none,
                        child: SizedBox(
                            width: 50, height: 50, child: UiUtils.progress()),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
