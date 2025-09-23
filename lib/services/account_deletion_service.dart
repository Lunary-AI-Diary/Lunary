import 'package:cloud_functions/cloud_functions.dart';

class AccountDeletionService {
  Future<void> deleteMyAccountOnServer() async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'deleteMyAccount',
    );
    await callable.call();
  }
}
