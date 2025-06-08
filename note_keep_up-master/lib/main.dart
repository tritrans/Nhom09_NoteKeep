import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_app/app/provider/app_provider.dart';
import 'core/config/routes/app_router.dart';
import 'features/presentation/blocs/auth/auth_bloc.dart';
import 'features/data/datasources/auth_service.dart';
import 'app/app.dart';
import 'app/di/get_it.dart' as di;
import 'package:hive/hive.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/services/notification_service.dart'; // Re-add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Xin quyền notification runtime trên Android
  if (defaultTargetPlatform == TargetPlatform.android) {
    await Permission.notification.request();
  }
  await di.init(); // Initialize GetIt first
  await di
      .gI<NotificationService>()
      .initialize(); // Get and initialize NotificationService
  runApp(AppProviders(child: const NoteApp()));
}

//sưa
