import 'package:flutter/material.dart';
import '../../core/theme/baule_colors.dart';

/// Widget pour les motifs géométriques Baoulé
/// Inspire par les patterns traditionnels des masques et textiles
class BauleGeometricPattern extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double scale;

  BauleGeometricPattern({
    this.primaryColor = BauleColors.gold,
    this.secondaryColor = BauleColors.deepBlack,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = primaryColor;
    final paint2 = Paint()..color = secondaryColor.withOpacity(0.1);

    // Diamants géométriques (motif traditionnel Baoulé)
    final diamondSize = 30 * scale;
    
    for (double x = 0; x < size.width; x += diamondSize * 2) {
      for (double y = 0; y < size.height; y += diamondSize * 2) {
        // Diamond 1
        _drawDiamond(canvas, Offset(x, y), diamondSize, paint2);
        
        // Diamond 2 (offset)
        _drawDiamond(canvas, Offset(x + diamondSize, y + diamondSize), diamondSize, paint);
      }
    }

    // Formes triangulaires aux coins
    _drawTrianglePattern(canvas, size, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);           // Haut
    path.lineTo(center.dx + size, center.dy);           // Droite
    path.lineTo(center.dx, center.dy + size);           // Bas
    path.lineTo(center.dx - size, center.dy);           // Gauche
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawTrianglePattern(Canvas canvas, Size size, Paint paint) {
    final triangleSize = 40 * scale;
    
    // Coin haut-gauche
    _drawTriangle(canvas, Offset(0, 0), triangleSize, paint, true);
    
    // Coin haut-droit
    _drawTriangle(canvas, Offset(size.width, 0), triangleSize, paint, false);
    
    // Coin bas-gauche
    _drawTriangle(canvas, Offset(0, size.height), triangleSize, paint, false);
    
    // Coin bas-droit
    _drawTriangle(canvas, Offset(size.width, size.height), triangleSize, paint, true);
  }

  void _drawTriangle(Canvas canvas, Offset corner, double size, Paint paint, bool isTopLeft) {
    final path = Path();
    
    if (isTopLeft) {
      path.moveTo(corner.dx, corner.dy);
      path.lineTo(corner.dx + size, corner.dy);
      path.lineTo(corner.dx, corner.dy + size);
    } else {
      path.moveTo(corner.dx, corner.dy);
      path.lineTo(corner.dx - size, corner.dy);
      path.lineTo(corner.dx, corner.dy + size);
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BauleGeometricPattern oldDelegate) => false;
}

/// Widget pour afficher les motifs géométriques Baoulé
class BaulePatternBackground extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final Color? backgroundColor;
  final double opacity;

  const BaulePatternBackground({
    Key? key,
    this.primaryColor = BauleColors.gold,
    this.secondaryColor = BauleColors.deepBlack,
    this.backgroundColor,
    this.opacity = 0.15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? BauleColors.creamWhite,
      child: CustomPaint(
        painter: BauleGeometricPattern(
          primaryColor: primaryColor.withOpacity(opacity),
          secondaryColor: secondaryColor,
        ),
        child: Container(),
      ),
    );
  }
}

/// Widget pour la bordure décorative Baoulé
class BauleDecorationBorder extends StatelessWidget {
  final double thickness;
  final double height;
  final bool isTop;

  const BauleDecorationBorder({
    Key? key,
    this.thickness = 4,
    this.height = 40,
    this.isTop = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: isTop
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  BauleColors.gold.withOpacity(0.4),
                  BauleColors.gold.withOpacity(0.1),
                ],
              )
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  BauleColors.gold.withOpacity(0.1),
                  BauleColors.gold.withOpacity(0.4),
                ],
              ),
      ),
      child: Stack(
        children: [
          // Motifs répétitifs
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                8,
                (index) => Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: BauleColors.gold,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Ligne dorée
          Positioned(
            left: 0,
            right: 0,
            top: isTop ? height - thickness : 0,
            child: Container(
              height: thickness,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    BauleColors.gold.withOpacity(0.3),
                    BauleColors.gold,
                    BauleColors.gold.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour les cercles Baoulé (symbolisant l'unité et l'harmonie)
class BauleCirclePattern extends StatelessWidget {
  final Color color;
  final double size;
  final Alignment alignment;

  const BauleCirclePattern({
    Key? key,
    this.color = BauleColors.gold,
    this.size = 80,
    this.alignment = Alignment.topRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0),
            ],
          ),
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 1,
              ),
            ),
            child: Center(
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
