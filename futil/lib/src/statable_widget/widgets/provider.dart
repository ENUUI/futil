import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state.dart';
import 'widgets.dart';

/// A provider that provides [RefreshHeader], [RefreshFooter] and [StateWidget].
class StatableProvider extends ChangeNotifier {
  static StatableProvider? maybeOf(BuildContext context) {
    try {
      return Provider.of<StatableProvider>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  StatableProvider({
    this.header,
    this.footer,
    this.stateWidget,
  });

  final StateWidget? stateWidget;
  final RefreshHeader? header;
  final RefreshFooter? footer;
}
