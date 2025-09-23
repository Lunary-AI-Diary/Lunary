import 'package:cloud_functions/cloud_functions.dart';

class AccountDeletionService {
  Future<void> deleteMyAccountOnServer() async {
    final functions = FirebaseFunctions.instanceFor(region: 'asia-northeast3');
    final callable = functions.httpsCallable('deleteMyAccount');
    await callable.call();
  }
}
