import 'package:flutter/material.dart';
import '../../../../core/widgets/widgets.dart';

class CommonFixScrolling extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const CommonFixScrolling({
    Key? key,
    required this.onRefresh,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: CommonSearchBar(),
            ),
            Expanded(
              child: SizedBox(
                height: constraints.maxHeight,
                child: RefreshIndicator(
                  onRefresh: onRefresh,
                  edgeOffset: 90,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
