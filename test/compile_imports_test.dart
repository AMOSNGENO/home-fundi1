import 'package:flutter_test/flutter_test.dart';
import 'package:home_fundi/main.dart';
import 'package:home_fundi/screens/admin/dashboard_stats.dart';
import 'package:home_fundi/screens/customer/post_request.dart';
import 'package:home_fundi/screens/login_screen.dart';
import 'package:home_fundi/screens/technician/technician_dashboard.dart';
import 'package:home_fundi/services/php_api_service.dart';

void main() {
  test('auth and dashboard modules compile', () {
    expect(HomeFundiApp, isNotNull);
    expect(LoginScreen, isNotNull);
    expect(PostRequestScreen, isNotNull);
    expect(DashboardStatsScreen, isNotNull);
    expect(TechnicianDashboardScreen, isNotNull);
    expect(PhpApiService, isNotNull);
  });
}
