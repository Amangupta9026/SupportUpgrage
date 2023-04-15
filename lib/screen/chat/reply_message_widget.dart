import 'package:flutter/material.dart';

import '../../global/color.dart';

class ReplyMessageWidget extends StatefulWidget {
  final String? senderName;
  final String? message;
  final VoidCallback? onCancelReply;
  final bool isReplyDesign;
  final bool textColor;
  final String chatDocId;

  const ReplyMessageWidget({
    @required this.message,
    this.senderName,
    this.onCancelReply,
    this.chatDocId = '',
    this.isReplyDesign = false,
    this.textColor = false,
    Key? key,
  }) : super(key: key);

  @override
  State<ReplyMessageWidget> createState() => _ReplyMessageWidgetState();
}

class _ReplyMessageWidgetState extends State<ReplyMessageWidget> {
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.green,
              width: 4,
            ),
            const SizedBox(width: 8),
            // if (widget.isReplyDesign == true) ...{
            Expanded(child: buildReplyMessage()),

            // } else ...{
            //   SizedBox(
            //       width: MediaQuery.of(context).size.width * 0.4,
            //       child: buildReplyMessage()),
            // }
          ],
        ),
      );

  Widget buildReplyMessage() => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    key: ValueKey(widget.chatDocId),
              
                    widget.senderName ?? '',
                    style: const TextStyle(
                        color: colorRed, fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.onCancelReply != null)
                  SizedBox(
                    width: 50,
                    child: InkWell(
                      onTap: widget.onCancelReply,
                      child: const Icon(Icons.close, size: 20),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 8),
            if (widget.textColor == true) ...{
              Text(widget.message.toString(),
                  style: const TextStyle(color: colorWhite)),
            } else ...{
              Text(widget.message.toString(),
                  style: const TextStyle(color: colorBlack)),
            },
          ],
        ),
      );
}
