import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../theme/app_colors.dart';
import '../widgets/example_card_body.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const _card = FFStyle(
    padding: FFSpacing(all: FFValue(xs: 12, md: 20)),
    backgroundColor: FFValue(xs: AppColors.surface),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FFContainer(
        maxSize: 1280,
        child: FFStyled(
          style: const FFStyle(
            padding: FFSpacing(all: FFValue(xs: 16, md: 32)),
          ),
          child: FFFlex(
            gap: const FFValue(xs: 16, md: 24),
            children: [
              const FFStyledItem(
                style: FFStyle(
                  textStyle: FFValue(
                    xs: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    md: TextStyle(fontSize: 30),
                  ),
                ),
                child: Text('Orders'),
              ),
              FFFlex(
                direction: const FFValue.all(FFDirectionEnum.horizontal),
                gap: const FFValue(xs: 12, md: 16),
                children: [
                  for (final (title, value) in [
                    ('Today', '24'),
                    ('This week', '183'),
                    ('Pending', '7'),
                    ('Revenue', '\$4.2k'),
                  ])
                    FFStyledItem(
                      col: const FFValue(xs: 12, sm: 6, lg: 3),
                      style: _card,
                      child: ExampleCardBody(value, title),
                    ),
                ],
              ),
              FFFlex(
                direction: const FFValue.all(FFDirectionEnum.horizontal),
                gap: const FFValue.all(12),
                crossAxisAlignment: const FFValue.all(
                  CrossAxisAlignment.center,
                ),
                children: [
                  const FFStyledItem(
                    col: FFValue(xs: 12, md: 3),
                    style: _card,
                    child: ExampleCardBody('Filters', 'col: xs 12, md 3'),
                  ),
                  const FFStyledItem(
                    fill: FFValue.all(true),
                    style: _card,
                    child: ExampleCardBody('Search orders…', 'fill: true'),
                  ),
                  FFItem(
                    fill: const FFValue.all(false),
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text('New'),
                    ),
                  ),
                ],
              ),
              FFFlex(
                direction: const FFValue(
                  xs: FFDirectionEnum.vertical,
                  md: FFDirectionEnum.horizontal,
                ),
                gap: const FFValue(xs: 12, md: 16),
                children: [
                  FFStyledItem(
                    col: const FFValue(md: 7, xl: 8),
                    style: _card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ExampleCardBody('Order list', 'col: md 7, xl 8'),
                        for (var i = 1; i <= 4; i++)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.receipt_long_outlined),
                            title: Text('Pedido #10$i'),
                            trailing: Text('\$${i * 35}.00'),
                          ),
                      ],
                    ),
                  ),
                  const FFStyledItem(
                    fill: FFValue(md: true),
                    style: FFStyle(
                      padding: FFSpacing(all: FFValue(xs: 12, md: 20)),
                      backgroundColor: FFValue(xs: AppColors.primarySoft),
                      visible: FFValue(xs: false, md: true),
                    ),
                    child: ExampleCardBody(
                      'Order details',
                      'fill: md true · oculto en xs/sm',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
