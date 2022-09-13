import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:task_manager/services/theme_services.dart';
import 'package:task_manager/ui/home_page.dart';
import 'package:task_manager/ui/theme.dart';

import 'db/db_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDb();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Management App',
      debugShowCheckedModeBanner: false,
      theme: Themes.light,
      themeMode: ThemeService().theme,
      darkTheme: Themes.dark,

      home: HomePage(),
    );
  }
}
