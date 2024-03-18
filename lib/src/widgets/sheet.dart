import 'package:flutter/material.dart';

import '../win.dart';
import 'space.dart';

// class Sheet {
//   Sheet._();
//
//   static Future<T?> show<T>(BuildContext context) {
//     return showModalBottomSheet(
//         context: context,
//         builder: (context) => Container(
//               height: 440,
//             ));
//   }
// }

class ActionSheet extends StatelessWidget {
  static Future<void> show(
    BuildContext context, {
    String title = '提示',
    String content = '',
    TextAlign contentAlign = TextAlign.left,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      routeSettings:
          const RouteSettings(name: 'half.module.common.action_sheet'),
      builder: (context) {
        return ActionSheet._(
            title: title, content: content, contentAlign: contentAlign);
      },
    );
    if (result == null || !result) {
      throw Exception('cancel');
    }
  }

  const ActionSheet._(
      {required this.title, required this.content, required this.contentAlign});

  final String title;
  final String content;
  final TextAlign contentAlign;

  @override
  Widget build(BuildContext context) {
    assert(title.isNotEmpty || content.isNotEmpty,
        'title and content cannot be empty at the same time');

    final DialogTheme dialogTheme = Theme.of(context).dialogTheme;
    final actionStyle = dialogTheme.contentTextStyle?.copyWith(
          fontWeight: FontWeight.w400,
        ) ??
        const TextStyle(
          fontWeight: FontWeight.w400,
        );
    return CustomActionsSheet(
      title: title,
      content: content,
      contentAlign: contentAlign,
      actions: Row(
        children: [
          Expanded(
            child: MaterialButton(
              height: 46,
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                '取消',
                style: actionStyle,
              ),
            ),
          ),
          Expanded(
            child: MaterialButton(
              height: 46,
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                '确定',
                style: actionStyle.copyWith(
                  color: dialogTheme.titleTextStyle?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomActionsSheet extends StatelessWidget {
  const CustomActionsSheet({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.contentAlign = TextAlign.left,
  });

  final String title;
  final String content;
  final Widget actions;
  final TextAlign contentAlign;

  @override
  Widget build(BuildContext context) {
    assert(title.isNotEmpty || content.isNotEmpty,
        'title and content cannot be empty at the same time');

    final DialogTheme dialogTheme = Theme.of(context).dialogTheme;

    final children = <Widget>[const Blank.vertical(size: 20)];

    if (title.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Text(
          title,
          style: dialogTheme.titleTextStyle,
          textAlign: TextAlign.center,
        ),
      ));
    }

    if (content.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Text(
          content,
          style: dialogTheme.contentTextStyle,
          textAlign: contentAlign,
          maxLines: 10000,
        ),
      ));
    }

    return _ActionSheetWrap(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
      actions: actions,
    );
  }
}

class _ActionSheetWrap extends StatelessWidget {
  const _ActionSheetWrap({required this.content, required this.actions});

  final Widget content;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final DialogTheme dialogTheme = Theme.of(context).dialogTheme;
    const padding = 20.0;
    return Container(
      decoration: BoxDecoration(
        color: dialogTheme.backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(36.0)),
      ),
      margin: EdgeInsets.only(
          bottom: Win.bottomSafe(context) + padding,
          left: padding,
          right: padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 138),
            child: content,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: actions,
          ),
        ],
      ),
    );
  }
}
