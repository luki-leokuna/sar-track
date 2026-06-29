// GPS Settings floating menu untuk MapView
// Letakkan ini di top-right MapView body

import 'package:flutter/material.dart';

class GpsSettingsFloatingMenu extends StatefulWidget {
  final double currentInterval;
  final bool isLeader;
  final Function(double) onIntervalChanged;
  final VoidCallback onClose;

  const GpsSettingsFloatingMenu({
    Key? key,
    required this.currentInterval,
    required this.isLeader,
    required this.onIntervalChanged,
    required this.onClose,
  }) : super(key: key);

  @override
  State<GpsSettingsFloatingMenu> createState() =>
      _GpsSettingsFloatingMenuState();
}

class _GpsSettingsFloatingMenuState extends State<GpsSettingsFloatingMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  double _tempInterval = 0;

  @override
  void initState() {
    super.initState();
    _tempInterval = widget.currentInterval;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.5, -0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF131A26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.settings,
                      color: Color(0xFFFF6600),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'GPS Update Interval',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: const Icon(Icons.close, color: Colors.grey, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Status: Leader/Member ───────────────────────────────────────
            if (!widget.isLeader)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.5),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hanya leader yang bisa mengubah interval',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),

            if (!widget.isLeader) const SizedBox(height: 12),

            // ── Current Value Display ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_tempInterval.toStringAsFixed(1)}m',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6600),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getIntervalType(_tempInterval),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getBatteryInfo(_tempInterval),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '🔋 Battery',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Slider ──────────────────────────────────────────────────────
            if (widget.isLeader)
              Column(
                children: [
                  Slider(
                    value: _tempInterval,
                    min: 1.0,
                    max: 10.0,
                    divisions: 18,
                    onChanged: (value) {
                      setState(() {
                        _tempInterval = double.parse(value.toStringAsFixed(1));
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '1m',
                        style: TextStyle(fontSize: 9, color: Color(0xFF6C757D)),
                      ),
                      Text(
                        '5m',
                        style: TextStyle(fontSize: 9, color: Color(0xFF6C757D)),
                      ),
                      Text(
                        '10m',
                        style: TextStyle(fontSize: 9, color: Color(0xFF6C757D)),
                      ),
                    ],
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Interval saat ini: ${widget.currentInterval.toStringAsFixed(1)}m',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ── Info Box ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue, size: 14),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Perubahan berlaku real-time. Semua anggota akan menerima notifikasi.',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (widget.isLeader) const SizedBox(height: 16),

            // ── Action Buttons ──────────────────────────────────────────────
            if (widget.isLeader)
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: widget.onClose,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_tempInterval != widget.currentInterval) {
                          widget.onIntervalChanged(_tempInterval);
                        }
                        widget.onClose();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Terapkan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF131A26,
                    ).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getIntervalType(double interval) {
    if (interval <= 1.5) return 'Ultra-responsive';
    if (interval <= 2.5) return 'High responsive';
    if (interval <= 4.0) return 'Balanced';
    if (interval <= 5.0) return 'Moderate';
    return 'Battery saving';
  }

  String _getBatteryInfo(double interval) {
    if (interval == 1.0) return '2.5%/hour';
    if (interval == 1.5) return '2.3%/hour';
    if (interval == 2.0) return '2.1%/hour';
    if (interval == 2.5) return '2%/hour';
    if (interval == 3.0) return '2%/hour';
    if (interval == 3.5) return '2%/hour';
    if (interval == 4.0) return '1.8%/hour';
    if (interval == 4.5) return '1.7%/hour';
    if (interval == 5.0) return '1.5%/hour';
    if (interval == 7.5) return '1.1%/hour';
    return '0.8%/hour';
  }
}
