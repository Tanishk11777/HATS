import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hats/extensions/buildcontext/loc.dart';
import 'package:hats/services/auth/bloc/auth_bloc.dart';
import 'package:hats/services/auth/bloc/auth_event.dart';
import 'package:hats/services/auth/bloc/auth_state.dart';
import 'package:hats/utilities/error_dialog.dart';
import 'package:hats/utilities/password_reset_email_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(
              context,
              context.loc.forgot_password_view_generic_error,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.loc.forgot_password,
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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                children: [
                  Text(
                    context.loc.forgot_password_view_prompt,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autofocus: true,
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: context.loc.email_text_field_placeholder,
                      hintStyle: TextStyle(color: Colors.white70),
                      fillColor: Colors.white.withOpacity(0.2),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {
                        final email = _controller.text;
                        context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                      },
                      child: Text(
                        context.loc.forgot_password_view_send_me_link,
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
                      context.loc.forgot_password_view_back_to_login,
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
