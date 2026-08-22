import 'package:flutter/material.dart';

// Stroke-based Lucide-style icons matching the Tera design spec (shared.jsx).
// All icons use a 24×24 viewbox, strokeWidth=1.8, round caps/joins, fill=none.

class TeraBagIcon extends StatelessWidget {
  const TeraBagIcon({required this.color, super.key, this.size = 20});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _BagPainter(color));
}

class TeraWarehouseIcon extends StatelessWidget {
  const TeraWarehouseIcon({required this.color, super.key, this.size = 20});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _WarehousePainter(color));
}

class TeraTruckIcon extends StatelessWidget {
  const TeraTruckIcon({required this.color, super.key, this.size = 20});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _TruckPainter(color));
}

class TeraUserIcon extends StatelessWidget {
  const TeraUserIcon({required this.color, super.key, this.size = 20});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _UserPainter(color));
}

class TeraSearchIcon extends StatelessWidget {
  const TeraSearchIcon({required this.color, super.key, this.size = 20});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _SearchPainter(color));
}

class TeraBellIcon extends StatelessWidget {
  const TeraBellIcon({required this.color, super.key, this.size = 20});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _BellPainter(color));
}

class TeraGlobeIcon extends StatelessWidget {
  const TeraGlobeIcon({required this.color, super.key, this.size = 20});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _GlobePainter(color));
}

class TeraLockIcon extends StatelessWidget {
  const TeraLockIcon({required this.color, super.key, this.size = 20});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _LockPainter(color));
}

// ─── Painters ────────────────────────────────────────────────────────────────

Paint _stroke(Color color, double scale) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.8 * scale
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

// bag: <rect x="3" y="7" width="18" height="13" rx="2"/>
//      <path d="M8 11V7a4 4 0 0 1 8 0v4"/>
class _BagPainter extends CustomPainter {
  const _BagPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = _stroke(color, s);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3 * s, 7 * s, 18 * s, 13 * s),
        Radius.circular(2 * s),
      ),
      p,
    );

    final path = Path()
      ..moveTo(8 * s, 11 * s)
      ..lineTo(8 * s, 7 * s)
      ..arcToPoint(Offset(16 * s, 7 * s),
          radius: Radius.circular(4 * s))
      ..lineTo(16 * s, 11 * s);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_BagPainter o) => o.color != color;
}

// warehouse: <path d="M3 21V9l9-5 9 5v12"/>
//            <path d="M9 21v-7h6v7"/>
class _WarehousePainter extends CustomPainter {
  const _WarehousePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = _stroke(color, s);

    // Outer outline: left wall → roof peak → right wall
    final outer = Path()
      ..moveTo(3 * s, 21 * s)
      ..lineTo(3 * s, 9 * s)
      ..lineTo(12 * s, 4 * s)
      ..lineTo(21 * s, 9 * s)
      ..lineTo(21 * s, 21 * s);
    canvas.drawPath(outer, p);

    // Door
    final door = Path()
      ..moveTo(9 * s, 21 * s)
      ..lineTo(9 * s, 14 * s)
      ..lineTo(15 * s, 14 * s)
      ..lineTo(15 * s, 21 * s);
    canvas.drawPath(door, p);
  }

  @override
  bool shouldRepaint(_WarehousePainter o) => o.color != color;
}

// truck: <rect x="1" y="6" width="14" height="11" rx="1.5"/>
//        <path d="M15 9h4l3 4v4h-7"/>
//        <circle cx="6" cy="19" r="2"/>
//        <circle cx="18" cy="19" r="2"/>
class _TruckPainter extends CustomPainter {
  const _TruckPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = _stroke(color, s);

    // Cargo box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1 * s, 6 * s, 14 * s, 11 * s),
        Radius.circular(1.5 * s),
      ),
      p,
    );

    // Cab: M15,9 H19 L22,13 V17 H15
    final cab = Path()
      ..moveTo(15 * s, 9 * s)
      ..lineTo(19 * s, 9 * s)
      ..lineTo(22 * s, 13 * s)
      ..lineTo(22 * s, 17 * s)
      ..lineTo(15 * s, 17 * s);
    canvas
      ..drawPath(cab, p)
      ..drawCircle(Offset(6 * s, 19 * s), 2 * s, p)
      ..drawCircle(Offset(18 * s, 19 * s), 2 * s, p);
  }

  @override
  bool shouldRepaint(_TruckPainter o) => o.color != color;
}

// user: <circle cx="12" cy="8" r="4"/>
//       <path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8"/>
class _UserPainter extends CustomPainter {
  const _UserPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = _stroke(color, s);

    // Head
    canvas.drawCircle(Offset(12 * s, 8 * s), 4 * s, p);

    // Body arc: M4,21 cubic to (12,13) then smooth to (20,21)
    final body = Path()
      ..moveTo(4 * s, 21 * s)
      ..cubicTo(4 * s, 16.6 * s, 7.6 * s, 13 * s, 12 * s, 13 * s)
      ..cubicTo(16.4 * s, 13 * s, 20 * s, 16.6 * s, 20 * s, 21 * s);
    canvas.drawPath(body, p);
  }

  @override
  bool shouldRepaint(_UserPainter o) => o.color != color;
}

// search: <circle cx="11" cy="11" r="7"/>
//         <path d="m20 20-3.5-3.5"/>
class _SearchPainter extends CustomPainter {
  const _SearchPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = _stroke(color, s);

    canvas.drawCircle(Offset(11 * s, 11 * s), 7 * s, p);

    final handle = Path()
      ..moveTo(20 * s, 20 * s)
      ..lineTo(16.5 * s, 16.5 * s);
    canvas.drawPath(handle, p);
  }

  @override
  bool shouldRepaint(_SearchPainter o) => o.color != color;
}

// globe: <circle cx="12" cy="12" r="10"/>
//        <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
//        <line x1="2" y1="12" x2="22" y2="12"/>
class _GlobePainter extends CustomPainter {
  const _GlobePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = _stroke(color, s);

    canvas.drawCircle(Offset(12 * s, 12 * s), 10 * s, p);

    final oval = Path()
      ..moveTo(12 * s, 2 * s)
      ..arcToPoint(Offset(16 * s, 12 * s),
          radius: Radius.elliptical(15.3 * s, 15.3 * s))
      ..arcToPoint(Offset(12 * s, 22 * s),
          radius: Radius.elliptical(15.3 * s, 15.3 * s))
      ..arcToPoint(Offset(8 * s, 12 * s),
          radius: Radius.elliptical(15.3 * s, 15.3 * s))
      ..arcToPoint(Offset(12 * s, 2 * s),
          radius: Radius.elliptical(15.3 * s, 15.3 * s));
    canvas.drawPath(oval, p);

    canvas.drawLine(Offset(2 * s, 12 * s), Offset(22 * s, 12 * s), p);
  }

  @override
  bool shouldRepaint(_GlobePainter o) => o.color != color;
}

// lock: <rect width="18" height="11" x="3" y="11" rx="2"/>
//       <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
class _LockPainter extends CustomPainter {
  const _LockPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = _stroke(color, s);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3 * s, 11 * s, 18 * s, 11 * s),
        Radius.circular(2 * s),
      ),
      p,
    );

    final shackle = Path()
      ..moveTo(7 * s, 11 * s)
      ..lineTo(7 * s, 7 * s)
      ..arcToPoint(Offset(17 * s, 7 * s), radius: Radius.circular(5 * s))
      ..lineTo(17 * s, 11 * s);
    canvas.drawPath(shackle, p);
  }

  @override
  bool shouldRepaint(_LockPainter o) => o.color != color;
}

// bell: <path d="M18 8a6 6 0 1 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/>
//       <path d="M10 21a2 2 0 0 0 4 0"/>
class _BellPainter extends CustomPainter {
  const _BellPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = _stroke(color, s);

    // Bell body: dome arc + left side + bottom + right side
    final bell = Path()
      ..moveTo(18 * s, 8 * s)
      ..arcToPoint(
        Offset(6 * s, 8 * s),
        radius: Radius.circular(6 * s),
        clockwise: false,
        largeArc: true,
      )
      ..cubicTo(6 * s, 15 * s, 3 * s, 17 * s, 3 * s, 17 * s)
      ..lineTo(21 * s, 17 * s)
      ..cubicTo(21 * s, 17 * s, 18 * s, 15 * s, 18 * s, 8 * s);
    canvas.drawPath(bell, p);

    // Clapper
    final clapper = Path()
      ..moveTo(10 * s, 21 * s)
      ..arcToPoint(
        Offset(14 * s, 21 * s),
        radius: Radius.circular(2 * s),
        clockwise: false,
      );
    canvas.drawPath(clapper, p);
  }

  @override
  bool shouldRepaint(_BellPainter o) => o.color != color;
}
