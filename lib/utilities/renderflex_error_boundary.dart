import 'package:flutter/material.dart';

class RenderFlexErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function()? onRenderFlexError;

  const RenderFlexErrorBoundary({Key? key, required this.child, this.onRenderFlexError}) : super(key: key);

  @override
  _RenderFlexErrorBoundaryState createState() => _RenderFlexErrorBoundaryState();
}

class _RenderFlexErrorBoundaryState extends State<RenderFlexErrorBoundary> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return _hasError ? SizedBox.shrink() : _buildChild();
  }

  Widget _buildChild() {
    return LayoutBuilder(
      builder: (context, constraints) {
        try {
          return widget.child;
        } catch (e) {
          if (e is FlutterError && e.toString().contains('A RenderFlex overflowed')) {
            // Handle the RenderFlex error
            setState(() {
              _hasError = true;
            });

            if (widget.onRenderFlexError != null) {
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                widget.onRenderFlexError!();
              });
            }
          }
          return SizedBox.shrink(); // Return an empty widget to hide the error-causing widget
        }
      },
    );
  }
}
