import 'package:flutter/material.dart';

class Responsivelayout extends StatelessWidget {
  final Widget mobileScaffold;
  final Widget webScaffold;
  final Widget tabScaffold;
  Responsivelayout({
    super.key,
    required this.mobileScaffold,
    required this.tabScaffold,
    required this.webScaffold,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return mobileScaffold;
        } else if (constraints.maxWidth < 1100) {
          return tabScaffold;
        } else {
          return webScaffold;
        }
      },
    );
  }
}
