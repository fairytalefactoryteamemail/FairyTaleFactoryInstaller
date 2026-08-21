import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

void setupWindow() {
  doWhenWindowReady(() {
    const initialSize = Size(850, 550);
    appWindow.minSize = initialSize;
    appWindow.maxSize = initialSize; // قفل کردن ابعاد برای جلوگیری از ریسایز
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center; // باز شدن در مرکز صفحه
    appWindow.title = "TaleForger Setup Wizard";
    appWindow.show();
  });
}