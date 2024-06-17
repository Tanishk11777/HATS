import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hats/extensions/buildcontext/loc.dart';
//import 'package:hats/constants/routes.dart';
import 'package:hats/services/auth/auth_execeptions.dart';
import 'package:hats/services/auth/auth_service.dart';
import 'package:hats/services/auth/bloc/auth_bloc.dart';
import 'package:hats/services/auth/bloc/auth_event.dart';
import 'package:hats/services/auth/bloc/auth_state.dart';
import 'package:hats/utilities/error_dialog.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, context.loc.register_error_weak_password);
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, context.loc.register_error_email_already_in_use);
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, context.loc.register_error_generic);
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, context.loc.register_error_invalid_email);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.loc.register,
            style: TextStyle(color: Colors.white),
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
                  return CircularProgressIndicator(strokeWidth: 3);
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
                            SizedBox(height: 25),
                            SizedBox(
                              width: 170,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final email = _email.text;
                                  final password = _pass.text;
                                  context.read<AuthBloc>().add(AuthEventRegister(email, password));
                                },
                                child: Text(
                                  context.loc.register,
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0, // Remove elevation
                                  padding: EdgeInsets.zero, // Remove padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8), // Set button border radius
                                  ),
                                  primary: Colors.blue,
                                ),
                              ),
                            ),
                            SizedBox(height: 17),
                            GestureDetector(
                              onTap: () {
                                context.read<AuthBloc>().add(const AuthEventLogOut());
                              },
                              child: Text(
                                context.loc.register_view_already_registered,
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
    );
  }
}

class EmailVerification extends StatefulWidget {
  const EmailVerification({Key? key}) : super(key: key);

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.loc.verify_email,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black87, // Set the entire body to black87
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.loc.verify_email_view_prompt,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventSendEmailVerification(),);
                },
                child: Text(
                  context.loc.verify_email_send_email_verification,
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0, // Remove elevation
                  padding: EdgeInsets.zero, // Remove padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Set button border radius
                  ),
                  primary: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              Center( // Wrap the GestureDetector with Center widget
                child: GestureDetector(
                  onTap: () {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: Text(
                    context.loc.restart,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(child: SizedBox()), // This widget expands to fill available space
            ],
          ),
        ),
      ),
    );
  }
}

