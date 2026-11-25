import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import 'app_colors.dart';

const exampleCardStyle = FFStyle(
  padding: FFSpacing(all: FFValue(xs: 12, md: 20)),
  backgroundColor: FFValue(xs: AppColors.surface),
  height: FFValue.all(110),
);

const exampleLabelStyle = FFStyle(
  textStyle: FFValue(
    xs: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    md: TextStyle(fontSize: 22),
  ),
  color: AppColors.primary,
);
