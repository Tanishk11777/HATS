import 'package:flutter/material.dart';
import 'package:hats/extensions/buildcontext/loc.dart';
import 'package:hats/services/auth/auth_service.dart';
import 'package:hats/services/auth/bloc/auth_bloc.dart';
import 'package:hats/services/auth/bloc/auth_event.dart';
import 'package:hats/services/auth/bloc/auth_state.dart';
import 'package:hats/utilities/error_dialog.dart';
import 'package:hats/services/auth/auth_execeptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _pass;

  @override
  void initState() {
    _email = TextEditingController();
    _pass = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, context.loc.login_error_cannot_find_user);
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, context.loc.login_error_wrong_credentials);
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, context.loc.login_error_auth_error);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.loc.login,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        body: Container(
          color: Colors.black87,
          child: Padding(
            padding: EdgeInsets.all(20), // Add padding to the container
            child: FutureBuilder(
              future: AuthService.firebase().initialize(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('Not connected to the internet');
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height,
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: context.loc.email_text_field_placeholder,
                                  labelStyle: TextStyle(color: Colors.white),
                                  fillColor: Colors.white.withOpacity(0.2),
                                  filled: true,
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: _pass,
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: context.loc.password_text_field_placeholder,
                                  labelStyle: TextStyle(color: Colors.white),
                                  fillColor: Colors.white.withOpacity(0.2),
                                  filled: true,
                                ),
                              ),
                              SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: () async {
                                  final email = _email.text;
                                  final password = _pass.text;
                                  context.read<AuthBloc>().add(
                                    AuthEventLogIn(
                                      email,
                                      password,
                                    ),
                                  );
                                },
                                child: Text(
                                  context.loc.signIn,
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0, // Remove elevation
                                  padding: EdgeInsets.zero, // Remove padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  primary: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 17),
                              GestureDetector(
                                onTap: () async {
                                  context.read<AuthBloc>().add(
                                    const AuthEventForgotPassword(),
                                  );
                                },
                                child: Text(
                                  context.loc.forgot_password,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold, // Make the text bold
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              GestureDetector(
                                onTap: () async {
                                  context.read<AuthBloc>().add(
                                    const AuthEventShouldRegister(),
                                  );
                                },
                                child: Text(
                                  context.loc.login_view_not_registered_yet,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold, // Make the text bold
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  default:
                    return Text('Unexpected ConnectionState: ${snapshot.connectionState}');
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
