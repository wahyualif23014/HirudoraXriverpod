import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class Meteor {
  double x;
  double y;
  double speed;
  double size;
  Color color;
  final trail = <Offset>[];

  Meteor({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
  });

  // Fungsi untuk update posisi meteor
  void update() {
    trail.add(Offset(x, y));
    if (trail.length > 10) { // Batasi panjang ekor
      trail.removeAt(0);
    }

    // Gerakkan meteor ke bawah secara diagonal
    x -= speed / 2;
    y += speed;
  }
}

// Widget utama untuk background animasi
class AnimatedMeteorsBackground extends StatefulWidget {
  const AnimatedMeteorsBackground({super.key});

  @override
  State<AnimatedMeteorsBackground> createState() => _AnimatedMeteorsBackgroundState();
}

class _AnimatedMeteorsBackgroundState extends State<AnimatedMeteorsBackground> {
  final List<Meteor> meteors = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    // Buat 30 meteor di posisi acak saat widget pertama kali dibuat
    for (int i = 0; i < 30; i++) {
      meteors.add(_createMeteor(Size.zero));
    }
  }

  // Fungsi untuk membuat satu meteor baru
  Meteor _createMeteor(Size size) {
    return Meteor(
      x: random.nextDouble() * (size.width + 200), // Mulai dari luar layar
      y: random.nextDouble() * -200, // Mulai dari atas layar
      speed: random.nextDouble() * 2 + 1, // Kecepatan acak
      size: random.nextDouble() * 2 + 1, // Ukuran acak
      color: Colors.white.withOpacity(random.nextDouble() * 0.5 + 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LoopAnimation akan terus-menerus membangun ulang widget ini
    return LoopAnimationBuilder<int>(
      tween: ConstantTween(1),
      duration: const Duration(milliseconds: 16),
      builder: (context, value, child) {
        final size = MediaQuery.of(context).size;

        // Update posisi setiap meteor
        for (var meteor in meteors) {
          meteor.update();
          // Jika meteor keluar layar, buat ulang di atas
          if (meteor.y > size.height + meteor.size || meteor.x < -meteor.size) {
            meteors[meteors.indexOf(meteor)] = _createMeteor(size);
          }
        }

        return CustomPaint(
          size: size,
          painter: MeteorPainter(meteors: meteors),
        );
      },
    );
  }
}

// Painter untuk menggambar semua meteor ke kanvas
class MeteorPainter extends CustomPainter {
  final List<Meteor> meteors;

  MeteorPainter({required this.meteors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var meteor in meteors) {
      // Gambar ekornya
      if (meteor.trail.isNotEmpty) {
        paint.shader = LinearGradient(
          colors: [meteor.color.withOpacity(0), meteor.color],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromPoints(meteor.trail.first, meteor.trail.last));

        final path = Path()..addPolygon(meteor.trail, false);
        paint.strokeWidth = meteor.size / 2;
        paint.style = PaintingStyle.stroke;
        canvas.drawPath(path, paint);
      }

      // Gambar kepala meteor
      paint.shader = null;
      paint.color = meteor.color;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(meteor.x, meteor.y), meteor.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}