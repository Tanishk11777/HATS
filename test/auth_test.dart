import 'package:hats/services/auth/auth_provider.dart';
import 'package:hats/services/auth/auth_user.dart';
import 'package:test/test.dart';
import '../lib/services/auth/auth_execeptions.dart';

void main(){
  group('Mock Authentication', (){
    final provider=MockAuthProvider();
    test('Should not be initialized to begin with',(){
      expect(provider.isInitialized,false);
    });
    test('Cannot log out if not initialized',(){
      expect(provider.logout(),
      throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test('should be able to be initialized', ()async{
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    
    test('user should be null after initialization', (){
      expect(provider.currentUser, null);
    });
    
    test('Should be able to initialize in less than 2 seconds', ()async{
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(const Duration(seconds: 2)));

    test('email verified function', (){
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test('should be able to logout and login', ()async{
      await provider.logout();
      await provider.login(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotIni implements Exception{}

class MockAuthProvider implements AuthProvider{
  AuthUser? _user;
  var _x=false;
  bool get isInitialized=> _x;
  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    if(!isInitialized) throw NotIni();
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _x=true;
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
    if(!isInitialized) throw NotIni();
    var user = AuthUser(isEmailVerified: false);
    _user=user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async{
    if(!isInitialized) throw NotIni();
    if(_user==null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user=null;
  }

  @override
  Future<void> sendEmailVerification() async{
    if(!isInitialized) throw NotIni();
    final user=_user;
    if(user==null) throw UserNotFoundAuthException();
    var newUser = AuthUser(isEmailVerified: true);
    _user=newUser;
  }
}