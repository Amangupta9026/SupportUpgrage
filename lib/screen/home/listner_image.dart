import 'package:flutter/material.dart';

class ListnerImage extends StatelessWidget {
  final Widget? image;
  const ListnerImage({Key? key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: InteractiveViewer(
              child: image!,
            ),
          ),
        ));
  }
}
