import 'package:flutter/material.dart';

import 'progress_helper.dart';

class ProgressContainerView extends StatefulWidget {
  final Widget? child;
  final Widget? progressWidget;
  final bool? isProgressRunning;
  final String progressText;
  final double? progressWidgetOpacity;

  const ProgressContainerView(
      {Key? key,
      required this.child,
      required this.isProgressRunning,
      this.progressText = "",
      this.progressWidgetOpacity = 0.6,
      this.progressWidget})
      : super(key: key);

  @override
  State<ProgressContainerView> createState() => _ProgressContainerViewState();
}

class _ProgressContainerViewState extends State<ProgressContainerView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child!,
        Visibility(
            visible: widget.isProgressRunning!,
            child: Container(
                color: Colors.white.withOpacity(0.6),
                child: widget.progressWidget ??
                    ProgressWidget(
                      progressText: widget.progressText,
                    ))),
      ],
    );
  }
}
