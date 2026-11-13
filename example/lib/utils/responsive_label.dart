import 'package:flutter/widgets.dart';
import 'package:flow_frame/flow_frame.dart';

String pxFor(FFValue<double> value, BuildContext context) =>
    '${(value.resolve(context.breakpoint) ?? 0).round()} px';
