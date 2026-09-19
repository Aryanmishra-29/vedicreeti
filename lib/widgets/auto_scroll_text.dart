import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class AutoScrollText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AutoScrollText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(minWidth: 0, maxWidth: double.infinity);

        if (textPainter.size.width > constraints.maxWidth) {
          return SizedBox(
            width: constraints.maxWidth,
            // Add a little padding to height so letters like 'g' or 'y' are not cut off
            height: textPainter.size.height + 2,
            child: Marquee(
              text: text,
              style: style,
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 30.0,
              velocity: 30.0,
              pauseAfterRound: const Duration(seconds: 2),
              startPadding: 0.0,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          );
        } else {
          return Text(
            text,
            style: style,
            textAlign: textAlign ?? TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
      },
    );
  }
}
