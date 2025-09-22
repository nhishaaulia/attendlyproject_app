import 'package:flutter/material.dart';

extension ExtendedNavigator on BuildContext {
  /// push → pindah ke halaman baru (stack di atas halaman sekarang)
  /// context.push(const DetailPage());
  Future<dynamic> push(Widget page, {String? name}) async {
    return Navigator.push(
      this,
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: name ?? page.runtimeType.toString()),
      ),
    );
  }

  /// pushReplacement → ganti halaman sekarang dengan halaman baru
  /// jadi halaman lama dihapus, diganti dengan yang baru
  /// context.pushReplacement(const HomePage());
  Future<dynamic> pushReplacement(Widget page, {String? name}) async {
    return Navigator.pushReplacement(
      this,
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: name ?? page.runtimeType.toString()),
      ),
    );
  }

  /// pushNamed → pindah ke halaman pakai route name (didaftarkan di MaterialApp routes)
  /// context.pushNamed('/home');
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) async {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  /// pushReplacementNamed → ganti halaman sekarang dengan halaman baru (pakai route name)
  /// hapus halaman sekarang lalu ganti dengan route name baru
  Future<dynamic> pushReplacementNamed(
    String newRouteName, {
    Object? arguments,
  }) {
    Navigator.popUntil(this, ModalRoute.withName(newRouteName));
    return Navigator.pushNamed(this, newRouteName, arguments: arguments);
  }

  /// pushNamedAndRemoveUntil → pindah ke halaman baru pakai route name,
  /// lalu hapus semua halaman di atas sampai ketemu predicate true
  /// context.pushNamedAndRemoveUntil('/login', (route) => false); // hapus semua
  Future<dynamic> pushNamedAndRemoveUntil(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) async {
    Navigator.pushNamedAndRemoveUntil(
      this,
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  /// pushNamedAndRemoveAll → pindah ke halaman baru pakai route name,
  /// lalu hapus semua halaman yang ada (stack jadi bersih)
  /// context.pushNamedAndRemoveAll('/dashboard');
  Future<dynamic> pushNamedAndRemoveAll(
    String newRouteName, {
    Object? arguments,
  }) async {
    Navigator.pushNamedAndRemoveUntil(
      this,
      newRouteName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// pop → kembali ke halaman sebelumnya
  /// bisa kirim result ke halaman sebelumnya
  ///context.pop(); atau context.pop('data balik');
  void pop([result]) async {
    return Navigator.of(this).pop(result);
  }
}
