import 'package:flutter/material.dart';
import 'package:web_responsive/web_responsive.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Uri.base.queryParameters['dark'] == '1';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: const WRTheme(
        data: WRThemeData(
          textStyle: WRValue(
            xs: TextStyle(fontSize: 14, height: 1.4),
            md: TextStyle(fontSize: 16),
          ),
        ),
        child: ExamplePage(),
      ),
    );
  }
}

const card = WRStyle(
  padding: WRSpacing(all: WRValue(xs: 12, md: 20)),
  backgroundColor: WRColor.surface,
  height: WRValue.all(110),
);

const label = WRStyle(
  textStyle: WRValue(
    xs: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    md: TextStyle(fontSize: 22),
  ),
  color: WRColor.primary,
);

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.wrColors.background,
      body: SingleChildScrollView(
        child: WRContainer(
          maxSize: 1280,
          style: const WRStyle(
            padding: WRSpacing(
              horizontal: WRValue(xs: 16, md: 32),
              vertical: WRValue(xs: 16, md: 32),
            ),
          ),
          child: WRFlex(
            gap: const WRValue(xs: 16, md: 24),
            children: [
              WRItem(
                style: const WRStyle(
                  textStyle: WRValue(
                    xs: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    md: TextStyle(fontSize: 34),
                  ),
                  textAlign: WRValue(xs: TextAlign.center, md: TextAlign.start),
                ),
                child: Text(
                  'Breakpoint actual: ${context.breakpoint.name} '
                  '(${MediaQuery.sizeOf(context).width.round()} px)',
                ),
              ),
              const WRItem(
                style: WRStyle(color: WRColor.textMuted),
                child: Text(
                  'Grilla con col: WRValue(xs: 12, md: 6, lg: 4). '
                  'Uno por fila en xs, dos en md y tres en lg; '
                  'lo que no cabe baja a la siguiente fila.',
                ),
              ),
              WRFlex(
                direction: const WRValue.all(Axis.horizontal),
                gap: const WRValue(xs: 12, md: 16),
                children: [
                  for (var i = 1; i <= 5; i++)
                    WRItem(
                      col: const WRValue(xs: 12, md: 6, lg: 4),
                      style: card.merge(const WRStyle(height: WRValue.all(80))),
                      child: _CardBody('Producto $i', 'col: xs 12, md 6, lg 4'),
                    ),
                ],
              ),
              const WRItem(
                style: WRStyle(color: WRColor.textMuted),
                child: Text(
                  'Mezcla en una fila: col 3, fill y un ícono de tamaño natural. '
                  'En xs el col 12 ocupa toda la fila y los otros bajan.',
                ),
              ),
              WRFlex(
                direction: const WRValue.all(Axis.horizontal),
                gap: const WRValue(xs: 12, md: 16),
                crossAxisAlignment: const WRValue.all(
                  CrossAxisAlignment.center,
                ),
                children: [
                  WRItem(
                    col: const WRValue(xs: 12, md: 3),
                    style: card.merge(const WRStyle(height: WRValue.all(80))),
                    child: const _CardBody('Filtros', 'col: xs 12, md 3'),
                  ),
                  WRItem(
                    fill: const WRValue.all(true),
                    style: card.merge(const WRStyle(height: WRValue.all(80))),
                    child: const _CardBody('Buscador', 'fill: true'),
                  ),
                  WRItem(
                    style: const WRStyle(color: WRColor.primary),
                    child: const Icon(Icons.tune, size: 32),
                  ),
                ],
              ),
              const WRItem(
                style: WRStyle(color: WRColor.textMuted),
                child: Text(
                  'WRFlex vertical en xs/sm y horizontal desde md. '
                  'La tarjeta B tiene visible: WRValue(xs: false, md: true).',
                ),
              ),
              WRFlex(
                direction: const WRValue(
                  xs: Axis.vertical,
                  md: Axis.horizontal,
                ),
                gap: const WRValue(xs: 12, md: 16),
                children: [
                  _card('A', 'fill: md true'),
                  WRItem(
                    fill: const WRValue(md: true),
                    style: card.merge(
                      const WRStyle(
                        visible: WRValue(xs: false, md: true),
                        backgroundColor: WRColor.adaptive(
                          light: Color(0xFFFFF4D6),
                          dark: Color(0xFF3A2E14),
                        ),
                      ),
                    ),
                    child: const _CardBody('B', 'oculta en xs/sm'),
                  ),
                  _card('C', 'fill: md true'),
                ],
              ),
              const WRItem(
                style: WRStyle(color: WRColor.textMuted),
                child: Text(
                  'Sidebar de 260 px y el contenido llena el resto, desde md',
                ),
              ),
              WRFlex(
                direction: const WRValue(
                  xs: Axis.vertical,
                  md: Axis.horizontal,
                ),
                gap: const WRValue(xs: 12, md: 16),
                children: [
                  WRItem(
                    style: card.merge(const WRStyle(width: WRValue(md: 260))),
                    child: const _CardBody('Sidebar', 'width: md 260'),
                  ),
                  WRItem(
                    fill: const WRValue(md: true),
                    style: card,
                    child: const _CardBody('Contenido', 'fill: md true'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  WRItem _card(String title, String note) => WRItem(
    fill: const WRValue(md: true),
    style: card,
    child: _CardBody(title, note),
  );
}

class _CardBody extends StatelessWidget {
  const _CardBody(this.title, this.note);

  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: label.toTextStyle(context)),
        const SizedBox(height: 4),
        Text(
          note,
          style: const WRStyle(color: WRColor.textMuted).toTextStyle(context),
        ),
      ],
    );
  }
}
