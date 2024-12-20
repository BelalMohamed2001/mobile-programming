import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import '../controllers/database_helper.dart';

class SyncManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

 
  Future<void> syncEvents(String userId) async {
    List<Map<String, dynamic>> pendingOperations =
        await DatabaseHelper.instance.fetchPendingOperations();

    for (var operation in pendingOperations) {
      if (operation['table_name'] == 'events') {
        var eventData = jsonDecode(operation['data']);
        bool synced = false;

        try {
          if (operation['operation'] == 'add') {
            await _firestore.collection('events').add(eventData);
          } else if (operation['operation'] == 'update') {
            await _firestore
                .collection('events')
                .doc(eventData['id'])
                .set(eventData);
          } else if (operation['operation'] == 'delete') {
            await _firestore.collection('events').doc(eventData['id']).delete();
            await DatabaseHelper.instance
                .deleteEvent(eventData['id']); 
          }
          synced = true;
        } catch (e) {
          print("Error syncing event: $e");
        }

        if (synced) {
          await DatabaseHelper.instance
              .updatePendingOperationStatus(operation['id'], 'completed');
        }
      }
    }
  }
 
  Future<void> syncGifts(String eventId) async {
    List<Map<String, dynamic>> pendingOperations =
        await DatabaseHelper.instance.fetchPendingOperations();

    for (var operation in pendingOperations) {
      if (operation['table_name'] == 'gifts') {
        var giftData = jsonDecode(operation['data']);
        bool synced = false;

        try {
          if (operation['operation'] == 'add') {
            await _firestore.collection('gifts').add(giftData);
          } else if (operation['operation'] == 'update') {
            await _firestore
                .collection('gifts')
                .doc(giftData['id'])
                .set(giftData);
          } else if (operation['operation'] == 'delete') {
            await _firestore.collection('gifts').doc(giftData['id']).delete();
            await DatabaseHelper.instance
                .deleteGift(giftData['id']); 
          }
          synced = true;
        } catch (e) {
          print("Error syncing gift: $e");
        }

        if (synced) {
          await DatabaseHelper.instance
              .updatePendingOperationStatus(operation['id'], 'completed');
        }
      }
    }
  }

  
  Future<void> syncUsers() async {
    List<Map<String, dynamic>> pendingOperations =
        await DatabaseHelper.instance.fetchPendingOperations();

    for (var operation in pendingOperations) {
      if (operation['table_name'] == 'users') {
        var userData = jsonDecode(operation['data']);
        bool synced = false;

        try {
          if (operation['operation'] == 'add') {
            await _firestore.collection('users').add(userData);
          } else if (operation['operation'] == 'update') {
            await _firestore
                .collection('users')
                .doc(userData['uid'])
                .set(userData);
          }
          synced = true;
        } catch (e) {
          print("Error syncing user: $e");
        }

        if (synced) {
          await DatabaseHelper.instance
              .updatePendingOperationStatus(operation['id'], 'completed');
        }
      }
    }
  }

  
  Future<void> syncAllData(String userId) async {
    if (await isOnline()) {
     
      await syncEvents(userId);
      await syncGifts(userId);

      
      await syncUsers();
    } else {
      print("Device is offline. Syncing will resume once online.");
    }
  }
}
