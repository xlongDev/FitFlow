import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../glass/glass.dart';

/// A rest timer that counts down from a target duration.
///
/// Shows a circular progress ring with the remaining seconds. When the timer
/// reaches zero, calls [onComplete].
///
/// The timer auto-starts when constructed. The user can pause, resume, skip,
/// or add 15 seconds.
class RestTimerWidget extends StatefulWidget {
  const RestTimerWidget({
    super.key,
    required this.durationSeconds,
    required this.onComplete,
    this.onDismiss,
  });

  /// The rest duration in seconds.
  final int durationSeconds;

  /// Called when the timer reaches zero.
  final VoidCallback onComplete;

  /// Called when the user dismisses the timer early.
  final VoidCallback? onDismiss;

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _tickTimer;
  int _remaining = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    )..reverse(from: 1.0);
    _startTicking();
  }

  void _startTicking() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && mounted) {
        setState(() {
          _remaining--;
        });
        if (_remaining <= 0) {
          _tickTimer?.cancel();
          _controller.stop();
          widget.onComplete();
        }
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _controller.stop();
      } else {
        _controller.reverse();
      }
    });
  }

  void _add15Seconds() {
    setState(() {
      _remaining += 15;
      _controller.duration = Duration(seconds: _remaining);
      _controller.reverse(from: _controller.value);
    });
  }

  void _skip() {
    _tickTimer?.cancel();
    _controller.stop();
    widget.onComplete();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = (_remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remaining % 60).toString().padLeft(2, '0');

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rest Timer', style: theme.textTheme.titleMedium),
              if (widget.onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: widget.onDismiss,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Circular progress ring
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CircularProgressIndicator(
                      value: _controller.value,
                      strokeWidth: 6,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: theme.colorScheme.primary,
                    );
                  },
                ),
                Text(
                  '$minutes:$seconds',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ControlButton(
                icon: _isPaused ? Icons.play_arrow : Icons.pause,
                label: _isPaused ? 'Resume' : 'Pause',
                onTap: _togglePause,
              ),
              _ControlButton(
                icon: Icons.add,
                label: '+15s',
                onTap: _add15Seconds,
              ),
              _ControlButton(
                icon: Icons.skip_next,
                label: 'Skip',
                onTap: _skip,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(height: AppSpacing.xs3),
          Text(
            label,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
