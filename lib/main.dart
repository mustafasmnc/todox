import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nodex/db/db_helper.dart';
import 'package:nodex/services/theme_services.dart';
import 'package:nodex/ui/home_page.dart';
import 'package:nodex/ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDB();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'NodeX',
        debugShowCheckedModeBanner: false,
        theme: Themes.light,
        darkTheme: Themes.dark,
        themeMode: ThemeService().theme,
        home: HomePage());
  }
}
