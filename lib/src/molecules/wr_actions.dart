import 'package:flutter/material.dart';

import '../models/wr_action.dart';
import '../utils/context_extensions.dart';

/// Acciones que cambian de forma según el breakpoint: ícono y texto, solo
/// ícono, dentro del menú ⋮ u ocultas.
///
/// Va en `AppBar.actions` (o en cualquier fila). El ⋮ aparece solo si
/// alguna acción está en [WRActionDisplay.menu] en el breakpoint actual.
class WRActions extends StatelessWidget {
  const WRActions({
    super.key,
    required this.actions,
    this.menuIcon = const Icon(Icons.more_vert),
    this.menuTooltip = 'Más opciones',
  });

  final List<WRAction> actions;

  /// Ícono del botón que abre el menú.
  final Widget menuIcon;
  final String menuTooltip;

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    WRActionDisplay displayOf(WRAction a) =>
        a.display?.resolve(breakpoint) ?? WRActionDisplay.icon;
    final inMenu = [
      for (final a in actions)
        if (displayOf(a) == WRActionDisplay.menu) a,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final a in actions)
          switch (displayOf(a)) {
            WRActionDisplay.full => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton.icon(
                onPressed: a.onPressed,
                icon: a.icon,
                label: Text(a.label),
              ),
            ),
            WRActionDisplay.icon => IconButton(
              tooltip: a.label,
              onPressed: a.onPressed,
              icon: a.icon,
            ),
            WRActionDisplay.menu ||
            WRActionDisplay.hidden => const SizedBox.shrink(),
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
