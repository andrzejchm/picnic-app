import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:picnic_app/features/posts/comment_chat/widgets/comment_chat_reply_bar.dart';
import 'package:picnic_app/features/posts/domain/model/basic_comment.dart';
import 'package:picnic_app/features/posts/domain/model/comment_preview.dart';
import 'package:picnic_app/features/posts/domain/model/tree_comment.dart';
import 'package:picnic_app/localization/app_localizations_utils.dart';
import 'package:picnic_app/resources/assets.gen.dart';
import 'package:picnic_app/ui/widgets/picnic_comment_text_input.dart';
import 'package:picnic_app/ui/widgets/picnic_container_icon_button.dart';
import 'package:picnic_ui_components/ui/theme/picnic_theme.dart';
import 'package:picnic_ui_components/ui/widgets/picnic_icon_button.dart';

class CommentChatInputBar extends StatelessWidget {
  const CommentChatInputBar({
    Key? key,
    required this.textController,
    this.hideInstantCommandsButton = false,
    this.hideAttachmentButton = false,
    this.replyingComment = const CommentPreview.empty(),
    this.onTapAttachment,
    this.onCommentUpdated,
    this.onTapElectric,
    this.onTapSend,
    this.textFieldFillColor,
    this.textFieldTextColor,
    this.onTapCancelReply,
    this.focusNode,
    this.endPadding = 0.0,
  }) : super(key: key);

  final BasicComment replyingComment;

  final bool hideAttachmentButton;
  final bool hideInstantCommandsButton;

  final VoidCallback? onTapElectric;
  final VoidCallback? onTapAttachment;
  final VoidCallback? onTapSend;
  final VoidCallback? onTapCancelReply;
  final ValueChanged<String>? onCommentUpdated;
  final Color? textFieldFillColor;
  final Color? textFieldTextColor;
  final TextEditingController textController;
  final FocusNode? focusNode;
  final double endPadding;

  @override
  Widget build(BuildContext context) {
    final theme = PicnicTheme.of(context);

    final blackAndWhite = theme.colors.blackAndWhite;
    final borderColor = blackAndWhite.shade300;

    const attachmentButtonsPadding = 5.0;
    const attachmentButtonsSize = 18.0 + attachmentButtonsPadding * 2;
    const sendButtonSize = 34.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        color: borderColor,
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(
          top: 1,
          left: 1,
          right: 1,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          color: blackAndWhite.shade100,
        ),
        child: Column(
          children: [
            if (replyingComment != const CommentPreview.empty() && replyingComment != const TreeComment.none()) ...[
              CommentChatReplyBar(
                comment: replyingComment,
                onTapCancelReply: onTapCancelReply,
              ),
              const Gap(14),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!hideAttachmentButton)
                      PicnicContainerIconButton(
                        iconPath: Assets.images.paperClip.path,
                        onTap: onTapAttachment,
                        buttonColor: Colors.transparent,
                        padding: attachmentButtonsPadding,
                        height: attachmentButtonsSize,
                        width: attachmentButtonsSize,
                      ),
                    if (!hideInstantCommandsButton)
                      PicnicContainerIconButton(
                        iconPath: Assets.images.electric.path,
                        onTap: onTapElectric,
                        buttonColor: Colors.transparent,
                        padding: attachmentButtonsPadding,
                        height: attachmentButtonsSize,
                        width: attachmentButtonsSize,
                      ),
                    const Gap(7),
                  ],
                ),
                Expanded(
                  child: PicnicCommentTextInput(
                    textController: textController,
                    hintText: appLocalizations.chatNewMessageInputHint,
                    fillColor: textFieldFillColor,
                    textColor: textFieldTextColor,
                    onChanged: onCommentUpdated,
                    focusNode: focusNode,
                    maxLines: null,
                    isDense: true,
                  ),
                ),
                const Gap(12),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(right: endPadding),
                    child: PicnicIconButton(
                      size: sendButtonSize,
                      icon: Assets.images.send.path,
                      color: theme.colors.green,
                      onTap: onTapSend,
                    ),
                  ),
                ),
                const Gap(5),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
