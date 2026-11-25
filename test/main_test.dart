import 'utils/utils_test.dart' as utils_test;
import 'molecules/molecules_test.dart' as molecules_test;
import 'public_api_test.dart' as public_api_test;
import 'models/models_test.dart' as models_test;
import 'enums/breakpoint_enum_test.dart' as breakpoint_enum_test;

void main() {
  molecules_test.main();
  utils_test.main();
  public_api_test.main();
  models_test.main();
  breakpoint_enum_test.main();
}
