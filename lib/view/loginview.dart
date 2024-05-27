import 'package:flutter/material.dart';
import 'package:hats/constants/routes.dart';
import 'package:hats/services/auth/auth_service.dart';
import 'package:hats/services/auth/bloc/auth_bloc.dart';
import 'package:hats/services/auth/bloc/auth_event.dart';
import 'package:hats/services/auth/bloc/auth_state.dart';
import 'package:hats/utilities/error_dialog.dart';
import 'package:hats/services/auth/auth_execeptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hats/utilities/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _pass;
  CloseDialog? _closeDialogHandle;

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
    return BlocListener<AuthBloc,AuthState>(
        listener: (context,state)async{
          if(state is AuthStateLoggedOut){
            final closeDialog=_closeDialogHandle;
            if(!state.isLoading && closeDialog!=null){
              closeDialog();
              _closeDialogHandle=null;
            }else if(state.isLoading && closeDialog==null){
              _closeDialogHandle=showLoadingDialog(context: context, text: 'Loading...');
            }
            if(state.exception is UserNotFoundAuthException){
              await showErrorDialog(context, 'User not found');
            }else if(state.exception is WrongPasswordAuthException){
              await showErrorDialog(context, 'Wrong Credentials');
            }else if(state.exception is GenericAuthException){
              await showErrorDialog(context, 'Authentication Error');
            }
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black87,
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
                  return Column(
                    children: [
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
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
                          labelText: 'Password',
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
                          child: Text('Sign in',
                            style: TextStyle(color: Colors.white),),
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
                            const AuthEventShouldRegister(),
                          );
                        },
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold, // Make the text bold
                          ),
                        ),
                      ),
                    ],
                  );
                }
              default:
                return Text('Unexpected ConnectionState: ${snapshot.connectionState}');
            }
          },
        ),
      ),
      backgroundColor: Colors.black87,
    ),
    );
  }
}

