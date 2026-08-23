import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/favorite_provider.dart';
import '../../theme/theme.dart';

/// A heart-shaped favorite toggle button with a scale + opacity animation.
///
/// Watches [isFavoriteProvider] to render the correct state, and calls
/// [FavoriteListNotifier.toggle] on tap. The animation plays on every
/// transition: the icon scales up briefly while the color swaps, giving a
/// tactile "pop" that matches Apple's favorite-button feel.
///
/// Used on the exercise detail page. The [size] and [onColor] parameters
/// adapt the button to light / dark backgrounds.
class FavoriteButton extends ConsumerStatefulWidget {
  const FavoriteButton({
    super.key,
    required this.exerciseId,
    this.size = 24,
    this.onColor = false,
  });

  /// The exercise this button toggles.
  final String exerciseId;

  /// Icon size.
  final double size;

  /// When `true`, renders a dark translucent background circle (for use on
  /// light image backgrounds). When `false`, renders no background.
  final bool onColor;

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimation.durationSm,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: AppAnimation.favoriteScale)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: AppAnimation.favoriteScale, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    // Play the animation forward immediately for instant feedback.
    _controller.forward(from: 0);
    await ref.read(favoriteListProvider.notifier).toggle(widget.exerciseId);
    // Invalidate the per-exercise favorite state so the icon updates.
    ref.invalidate(isFavoriteProvider(widget.exerciseId));
  }

  @override
  Widget build(BuildContext context) {
    final asyncIsFav = ref.watch(isFavoriteProvider(widget.exerciseId));
    final isFav = asyncIsFav.value ?? false;
    final theme = Theme.of(context);

    final icon = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        size: widget.size,
        color: isFav
            ? AppColors.secondary
            : (widget.onColor ? Colors.white : theme.colorScheme.onSurface),
      ),
    );

    if (widget.onColor) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: icon,
          tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
          onPressed: _toggle,
        ),
      );
    }

    return IconButton(
      icon: icon,
      tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
      onPressed: _toggle,
    );
  }
}
