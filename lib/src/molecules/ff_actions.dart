import 'package:flutter/material.dart';

import '../enums/ff_action_display_enum.dart';
import '../models/ff_action.dart';
import '../utils/context_extensions.dart';

/// Acciones que cambian de forma según el breakpoint: ícono y texto, solo
/// ícono, dentro del menú ⋮ u ocultas.
///
/// Va en `AppBar.actions` (o en cualquier fila). El ⋮ aparece solo si
/// alguna acción está en [FFActionDisplayEnum.menu] en el breakpoint actual.
class FFActions extends StatelessWidget {
  const FFActions({
    super.key,
    required this.actions,
    this.menuIcon = const Icon(Icons.more_vert),
    this.menuTooltip = 'Más opciones',
  });

  final List<FFAction> actions;

  /// Ícono del botón que abre el menú.
  final Widget menuIcon;
  final String menuTooltip;

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    FFActionDisplayEnum displayOf(FFAction a) =>
        a.display?.resolve(breakpoint) ?? FFActionDisplayEnum.icon;
    final inMenu = [
      for (final a in actions)
        if (displayOf(a) == FFActionDisplayEnum.menu) a,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final a in actions)
          switch (displayOf(a)) {
            FFActionDisplayEnum.full => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton.icon(
                onPressed: a.onPressed,
                icon: a.icon,
                label: Text(a.label),
              ),
            ),
            FFActionDisplayEnum.icon => IconButton(
              tooltip: a.label,
              onPressed: a.onPressed,
              icon: a.icon,
            ),
            FFActionDisplayEnum.menu ||
            FFActionDisplayEnum.hidden => const SizedBox.shrink(),
          },
        if (inMenu.isNotEmpty)
          MenuAnchor(
            alignmentOffset: const Offset(0, 4),
            builder: (context, controller, _) => IconButton(
              tooltip: menuTooltip,
              icon: menuIcon,
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
            ),
            menuChildren: [
              for (final a in inMenu)
                MenuItemButton(
                  leadingIcon: a.icon,
                  onPressed: a.onPressed,
                  child: Text(a.label),
                ),
            ],
          ),
      ],
    );
  }
}
