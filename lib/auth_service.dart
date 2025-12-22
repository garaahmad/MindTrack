// Dummy AuthService for local testing without Firebase
class AuthService {
  // Mock methods to prevent crashes
  Stream<dynamic> get userStream => const Stream.empty();
  dynamic get currentUser => null;

  Future<dynamic> signInWithGoogle() async {
    return null;
  }

  Future<void> signOut() async {
    return;
  }
}
