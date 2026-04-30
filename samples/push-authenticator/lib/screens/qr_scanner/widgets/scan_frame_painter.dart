// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import 'package:asgardeo_push_authenticator/constants/screens/qr_scanner.dart';
import 'package:flutter/material.dart';

/// Semi-transparent overlay with a rounded scan frame cut-out.
class ScanOverlay extends StatelessWidget {
  const ScanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    const frameSize = QrScannerConstants.frameSize;
    final screenSize = MediaQuery.of(context).size;
    final frameLeft = (screenSize.width - frameSize) / 2;
    final frameTop = (screenSize.height - frameSize) / 2;

    return CustomPaint(
      size: screenSize,
      painter: _ScanFramePainter(
        frameRect: Rect.fromLTWH(frameLeft, frameTop, frameSize, frameSize),
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  const _ScanFramePainter({required this.frameRect});

  final Rect frameRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()..color = Colors.black54;

    canvas
      ..drawRect(
        Rect.fromLTWH(0, 0, size.width, frameRect.top),
        overlay,
      )
      ..drawRect(
        Rect.fromLTWH(
          0,
          frameRect.bottom,
          size.width,
          size.height - frameRect.bottom,
        ),
        overlay,
      )
      ..drawRect(
        Rect.fromLTWH(0, frameRect.top, frameRect.left, frameRect.height),
        overlay,
      )
      ..drawRect(
        Rect.fromLTWH(
          frameRect.right,
          frameRect.top,
          size.width - frameRect.right,
          frameRect.height,
        ),
        overlay,
      );

    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(20)),
      border,
    );
  }

  @override
  bool shouldRepaint(_ScanFramePainter old) => false;
}
