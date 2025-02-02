import 'package:flutter/material.dart';
import 'package:picnic_app/ui/widgets/picnic_list_item.dart';
import 'package:picnic_ui_components/ui/theme/picnic_theme.dart';

class ProfileHorizontalItem extends StatelessWidget {
  const ProfileHorizontalItem({
    Key? key,
    required this.onTap,
    required this.trailingText,
    this.leading,
    required this.title,
    this.onTapTrailing,
  }) : super(key: key);

  final VoidCallback onTap;
  final VoidCallback? onTapTrailing;

  final String trailingText;
  final String title;

  final Widget? leading;

  static const double _itemHeight = 48;
  static const double _itemRadius = 12;

  @override
  Widget build(BuildContext context) {
    final theme = PicnicTheme.of(context);
    final styles = theme.styles;
    final colors = theme.colors;
    final blackAndWhite = colors.blackAndWhite;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: PicnicListItem(
        title: title,
        titleStyle: styles.title10,
        onTapDetails: onTapTrailing,
        onTap: onTap,
        height: _itemHeight,
        trailing: Text(
          trailingText,
          style: styles.body30.copyWith(color: colors.green),
        ),
        fillColor: blackAndWhite.shade200,
        borderRadius: _itemRadius,
        leading: leading,
      ),
    );
  }
}
