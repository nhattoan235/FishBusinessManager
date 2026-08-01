import 'package:drift/drift.dart';
// ignore: deprecated_member_use
import 'package:drift/web.dart';

QueryExecutor openDatabaseConnection({String? encryptionKey}) =>
    WebDatabase('fish_business_manager_db');
